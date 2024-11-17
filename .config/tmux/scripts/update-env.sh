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

# Read a single keypress
read_key() {
    # Turn off echoing and canonical mode
    stty -echo -icanon
    # Read a single character
    key=$(dd bs=1 count=1 2>/dev/null)
    # Restore terminal settings
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
    tmux_value="$(tmux show-environment | /usr/bin/grep "^${var_name}=" | cut -d= -f2)"
    shell_value="$(get_env_var "$var_name")"

    [ -z "$tmux_value" ] && tmux_value="Not Set"
    [ -z "$shell_value" ] && shell_value="Not Set"

    if [ "$tmux_value" = "$shell_value" ] && [ "$tmux_value" != "Not Set" ]; then
        status_symbol="${GREEN}●${RESET}"
    else
        status_symbol="${YELLOW}●${RESET}"
    fi

    printf "%b%-15s%b %s %-40s %s %-40s\n" \
        "$BOLD" "$var_name" "$RESET" \
        "$status_symbol" "$tmux_value" \
        "$status_symbol" "$shell_value"
}

# Create list of common environment variables to manage
vars="SSH_AUTH_SOCK SSH_CONNECTION DISPLAY PATH TERM LANG"

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
    printf "3) Exit\n\n"
    printf "Select option (1-3): "
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

                if echo "$var_choice" | /usr/bin/grep -q '^[0-9]\+$'; then
                    selected_var=$(echo "$vars" | tr ' ' '\n' | sed -n "${var_choice}p")
                    if [ -n "$selected_var" ]; then
                        printf "\n"
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
