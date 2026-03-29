#!/usr/bin/env sh
# ~/.config/tmux/scripts/update-env.sh
# Invoked via tmux bind-key e as a display-popup.
# Shows sync status of environment variables between tmux and current shell.
# SSH_AUTH_SOCK is intentionally excluded — it's a stable constant managed
# by launchd (Mac) or ~/.ssh/rc symlink (Linux).

ESC="$(printf '\033')"
BOLD="${ESC}[1m"
RESET="${ESC}[0m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
RED="${ESC}[31m"

read_key() {
    stty -echo -icanon
    key=$(dd bs=1 count=1 2>/dev/null)
    stty echo icanon
    case "$key" in
        q|Q|"$ESC") return 1 ;;
        *) printf "%s" "$key"; return 0 ;;
    esac
}

get_env_var() {
    printenv "$1" || echo ""
}

show_env_status() {
    var_name="$1"
    tmux_value="$(tmux show-environment 2>/dev/null | grep "^${var_name}=" | cut -d= -f2)"
    shell_value="$(get_env_var "$var_name")"

    [ -z "$tmux_value" ] && tmux_value="Not Set"
    [ -z "$shell_value" ] && shell_value="Not Set"

    if [ "$tmux_value" = "$shell_value" ] && [ "$tmux_value" != "Not Set" ]; then
        status_symbol="${GREEN}●${RESET}"
    else
        status_symbol="${YELLOW}●${RESET}"
    fi

    printf "%b%-25s%b %s %-40s %s %-40s\n" \
        "$BOLD" "$var_name" "$RESET" \
        "$status_symbol" "$tmux_value" \
        "$status_symbol" "$shell_value"
}

update_env_var() {
    var_name="$1"
    new_value="$(get_env_var "$var_name")"
    if [ -n "$new_value" ]; then
        tmux set-environment -g "$var_name" "$new_value"
        printf "%b✓%b Updated %s\n" "$GREEN" "$RESET" "$var_name"
    else
        printf "%b✗%b %s is not set\n" "$RED" "$RESET" "$var_name"
    fi
}

vars="DISPLAY TERM TERM_PROGRAM WEZTERM_UNIX_SOCKET PATH LANG"

show_menu() {
    clear
    printf "%bEnvironment Variable Status%b (q/ESC to quit)\n" "$BOLD" "$RESET"
    printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    printf "%b%-25s  %-41s %-40s%b\n" "$BOLD" "Variable" "Tmux Value" "Shell Value" "$RESET"
    printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"

    for var in $vars; do
        show_env_status "$var"
    done

    printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    printf "\n%bOptions:%b\n" "$BOLD" "$RESET"
    printf "1) Update all variables\n"
    printf "2) Exit\n\n"
    printf "Select option (1-2): "
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
            2) exit 0 ;;
            *)
                printf "\n%b✗%b Invalid option\n" "$RED" "$RESET"
                printf "\nPress any key to continue (q/ESC to quit)..."
                read_key || exit 0
                ;;
        esac
    done
fi
