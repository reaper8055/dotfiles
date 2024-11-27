#!/usr/bin/env sh

# Save as ~/.tmux/scripts/update-env.sh
# Make executable with: chmod +x ~/.tmux/scripts/update-env.sh

# ANSI color codes (POSIX-compliant)
ESC="$(printf '\033')"
BOLD="${ESC}[1m"
RESET="${ESC}[0m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
RED="${ESC}[31m"
BLUE="${ESC}[34m"

# Start or update ssh-agent
setup_ssh_agent() {
    if [ -z "$SSH_AGENT_PID" ] || ! ps -p "$SSH_AGENT_PID" > /dev/null; then
        printf "%bStarting new ssh-agent session...%b\n" "$BLUE" "$RESET"
        eval "$(ssh-agent)" > /dev/null
        printf "%b✓%b ssh-agent started with PID %s\n" "$GREEN" "$RESET" "$SSH_AGENT_PID"

        # Check if any keys are added
        if ! ssh-add -l >/dev/null 2>&1; then
            printf "%bNo SSH keys found. Adding default key...%b\n" "$YELLOW" "$RESET"
            if [ -f ~/.ssh/id_rsa ]; then
                ssh-add ~/.ssh/id_rsa
            elif [ -f ~/.ssh/id_ed25519 ]; then
                ssh-add ~/.ssh/id_ed25519
            else
                printf "%b✗%b No default SSH keys found. Please add manually with ssh-add\n" "$RED" "$RESET"
            fi
        fi
    else
        printf "%b✓%b ssh-agent already running with PID %s\n" "$GREEN" "$RESET" "$SSH_AGENT_PID"
    fi

    # Update SSH_AUTH_SOCK in tmux
    if [ -n "$SSH_AUTH_SOCK" ]; then
        tmux set-environment -g SSH_AUTH_SOCK "$SSH_AUTH_SOCK"
        printf "%b✓%b Updated SSH_AUTH_SOCK in tmux\n" "$GREEN" "$RESET"
    fi
}

# Check if ssh-agent is running
check_ssh_agent() {
    if [ -z "$SSH_AGENT_PID" ]; then
        printf "%b!%b ssh-agent is not running. Start it with:\n" "$YELLOW" "$RESET"
        printf "    eval \$(ssh-agent)\n"
        printf "    ssh-add\n"
        return 1
    fi
    return 0
}

# Read a single keypress
read_key() {
    stty -echo -icanon
    key=$(dd bs=1 count=1 2>/dev/null)
    stty echo icanon

    case "$key" in
        q|Q|"$ESC")
            return 1
            ;;
        *)
            printf "%s" "$key"
            return 0
            ;;
    esac
}

# Function to get environment variable value safely
get_env_var() {
    printenv "$1" || echo ""
}

# Function to update a specific environment variable
update_env_var() {
    var_name="$1"
    new_value="$(get_env_var "$var_name")"

    # Special handling for SSH_AUTH_SOCK
    if [ "$var_name" = "SSH_AUTH_SOCK" ]; then
        if ! check_ssh_agent; then
            return 1
        fi
    fi

    if [ -n "$new_value" ]; then
        tmux set-environment -g "$var_name" "$new_value"
        printf "%b✓%b Updated %s\n" "$GREEN" "$RESET" "$var_name"
    else
        printf "%b✗%b %s is not set in current environment\n" "$RED" "$RESET" "$var_name"
    fi
}

# Function to display status of environment variables
show_env_status() {
    var_name="$1"
    tmux_value="$(tmux show-environment | grep "^${var_name}=" | cut -d= -f2)"
    shell_value="$(get_env_var "$var_name")"

    [ -z "$tmux_value" ] && tmux_value="Not Set"
    [ -z "$shell_value" ] && shell_value="Not Set"

    # Special handling for SSH_AUTH_SOCK display
    if [ "$var_name" = "SSH_AUTH_SOCK" ]; then
        if ! check_ssh_agent >/dev/null 2>&1; then
            status_symbol="${RED}●${RESET}"
            shell_value="${RED}ssh-agent not running${RESET}"
        elif [ "$tmux_value" = "$shell_value" ] && [ "$tmux_value" != "Not Set" ]; then
            status_symbol="${GREEN}●${RESET}"
        else
            status_symbol="${YELLOW}●${RESET}"
        fi
    else
        if [ "$tmux_value" = "$shell_value" ] && [ "$tmux_value" != "Not Set" ]; then
            status_symbol="${GREEN}●${RESET}"
        else
            status_symbol="${YELLOW}●${RESET}"
        fi
    fi

    printf "%b%-15s%b %s %-40s %s %-40s\n" \
        "$BOLD" "$var_name" "$RESET" \
        "$status_symbol" "$tmux_value" \
        "$status_symbol" "$shell_value"
}

# Create list of common environment variables to manage
vars="SSH_AUTH_SOCK SSH_CONNECTION DISPLAY PATH TERM LANG"

# Show help message
show_help() {
    printf "\n%bCommon Issues:%b\n" "$BOLD" "$RESET"
    printf "1. If ssh-agent is not running:\n"
    printf "   %beval \$(ssh-agent)%b\n" "$BLUE" "$RESET"
    printf "   %bssh-add%b\n" "$BLUE" "$RESET"
    printf "\n2. If git signing is not working:\n"
    printf "   %bssh-add -L%b to list keys\n" "$BLUE" "$RESET"
    printf "   %bssh-add ~/.ssh/your_key%b to add specific key\n" "$BLUE" "$RESET"
    printf "\nPress any key to continue (q/ESC to quit)..."
    read_key || exit 0
}

# Show menu and get selection
show_menu() {
    clear
    printf "%bEnvironment Variable Status%b (press 'q' or ESC to quit)\n" "$BOLD" "$RESET"
    printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    printf "%bVariable        Tmux Value                                  Shell Value%b\n" "$BOLD" "$RESET"
    printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"

    for var in $vars; do
        show_env_status "$var"
    done

    printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    printf "\n%bOptions:%b\n" "$BOLD" "$RESET"
    printf "1) Update all variables\n"
    printf "2) Select specific variable\n"
    printf "3) Setup/Update ssh-agent\n"
    printf "4) Show help\n"
    printf "5) Exit\n\n"
    printf "Select option (1-5): "
}

if [ "$1" = "menu" ]; then
    while true; do
        show_menu
        if ! key=$(read_key); then
            exit 0
        fi

        case $key in
            1)
                printf "\n"
                setup_ssh_agent  # Always check/setup ssh-agent first
                for var in $vars; do
                    update_env_var "$var"
                done
                printf "\nPress any key to continue (q/ESC to quit)..."
                read_key || exit 0
                ;;
            2)
                printf "\n%bSelect variable to update:%b\n" "$BOLD" "$RESET"
                i=1
                for var in $vars; do
                    printf "%d) %s\n" "$i" "$var"
                    i=$((i + 1))
                done
                printf "\nSelect variable (1-%d): " "$(echo "$vars" | wc -w)"

                if ! var_choice=$(read_key); then
                    exit 0
                fi

                if echo "$var_choice" | grep -q '^[0-9]\+$'; then
                    selected_var=$(echo "$vars" | tr ' ' '\n' | sed -n "${var_choice}p")
                    if [ -n "$selected_var" ]; then
                        printf "\n"
                        [ "$selected_var" = "SSH_AUTH_SOCK" ] && setup_ssh_agent
                        update_env_var "$selected_var"
                    else
                        printf "\n%b✗%b Invalid selection\n" "$RED" "$RESET"
                    fi
                else
                    printf "\n%b✗%b Invalid selection\n" "$RED" "$RESET"
                fi
                printf "\nPress any key to continue (q/ESC to quit)..."
                read_key || exit 0
                ;;
            3)
                printf "\n"
                setup_ssh_agent
                printf "\nPress any key to continue (q/ESC to quit)..."
                read_key || exit 0
                ;;
            4)
                show_help
                ;;
            5)
                exit 0
                ;;
            *)
                printf "\n%b✗%b Invalid option\n" "$RED" "$RESET"
                printf "\nPress any key to continue (q/ESC to quit)..."
                read_key || exit 0
                ;;
        esac
    done
fi
