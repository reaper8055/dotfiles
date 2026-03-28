#!/usr/bin/env bash
# setup.sh — stow dotfiles based on platform
# Usage: ./setup.sh [--dry-run]
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

STOW_FLAGS="--target=$HOME --restow"
$DRY_RUN && STOW_FLAGS="$STOW_FLAGS --simulate"

info()  { printf "\033[0;34m[INFO]\033[0m  %s\n" "$*"; }
ok()    { printf "\033[0;32m[OK]\033[0m    %s\n" "$*"; }
error() { printf "\033[0;31m[ERROR]\033[0m %s\n" "$*" >&2; }

stow_package() {
    local pkg="$1"
    local pkg_path="$DOTFILES_DIR/packages/$pkg"
    if [[ ! -d "$pkg_path" ]]; then
        error "Package not found: $pkg_path"
        return 1
    fi
    info "Stowing package: $pkg"
    stow $STOW_FLAGS --dir="$DOTFILES_DIR/packages" "$pkg"
    ok "Stowed: $pkg"
}

post_install_darwin() {
    info "Running macOS post-install steps"
    chmod 700 "$HOME/.ssh/sk-askpass"
    chmod 700 "$HOME/.ssh/sk-helper-wrapper"
    launchctl unload "$HOME/Library/LaunchAgents/com.user.homebrew-ssh-agent.plist" 2>/dev/null || true
    launchctl load   "$HOME/Library/LaunchAgents/com.user.homebrew-ssh-agent.plist"
    ok "Launchd agent reloaded"
}

post_install_linux() {
    info "Running Linux post-install steps"
    if [[ -f "$HOME/.ssh/rc" ]]; then
        ok "~/.ssh/rc in place"
    else
        error "~/.ssh/rc missing — sshd agent forwarding symlink will not update"
    fi
}

main() {
    cd "$DOTFILES_DIR"

    stow_package "common"

    case "$OSTYPE" in
        darwin*)
            stow_package "darwin"
            $DRY_RUN && { info "Dry run — skipping post-install"; return; }
            post_install_darwin
            ;;
        linux-gnu*)
            stow_package "linux"
            $DRY_RUN && { info "Dry run — skipping post-install"; return; }
            post_install_linux
            ;;
        *)
            error "Unsupported platform: $OSTYPE"
            exit 1
            ;;
    esac

    ok "Setup complete"
}

main "$@"
