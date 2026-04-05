#!/usr/bin/env bash
# setup.sh — stow dotfiles based on platform and environment
# Usage:
#   ./setup.sh                    # personal machine
#   ./setup.sh --corp             # corp machine
#   ./setup.sh --dry-run          # simulate without modifying filesystem
#   ./setup.sh --clean            # remove all dotfiles symlinks
#   ./setup.sh --clean --corp     # remove only corp-mode symlinks
#   ./setup.sh --clean --dry-run  # simulate clean
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
CORP=false
CLEAN=false

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --corp)    CORP=true ;;
        --clean)   CLEAN=true ;;
    esac
done

STOW_FLAGS="--target=$HOME"
$DRY_RUN && STOW_FLAGS="$STOW_FLAGS --simulate"

info()  { printf "\033[0;34m[INFO]\033[0m  %s\n" "$*"; }
ok()    { printf "\033[0;32m[OK]\033[0m    %s\n" "$*"; }
warn()  { printf "\033[0;33m[WARN]\033[0m  %s\n" "$*"; }
error() { printf "\033[0;31m[ERROR]\033[0m %s\n" "$*" >&2; }

stow_package() {
    local pkg="$1"
    local pkg_path="$DOTFILES_DIR/packages/$pkg"
    if [[ ! -d "$pkg_path" ]]; then
        error "Package not found: $pkg_path"
        return 1
    fi
    info "Stowing package: $pkg"
    stow $STOW_FLAGS --restow --dir="$DOTFILES_DIR/packages" "$pkg"
    ok "Stowed: $pkg"
}

unstow_package() {
    local pkg="$1"
    local pkg_path="$DOTFILES_DIR/packages/$pkg"
    if [[ ! -d "$pkg_path" ]]; then
        warn "Package not found, skipping: $pkg"
        return 0
    fi
    info "Removing symlinks for package: $pkg"
    stow $STOW_FLAGS --delete --dir="$DOTFILES_DIR/packages" "$pkg"
    ok "Removed: $pkg"
}

post_install_darwin_personal() {
    info "Running macOS personal post-install steps"
    chmod 700 "$HOME/.ssh/sk-askpass"
    chmod 700 "$HOME/.ssh/sk-helper-wrapper"
    launchctl unload "$HOME/Library/LaunchAgents/com.user.homebrew-ssh-agent.plist" 2>/dev/null || true
    launchctl load   "$HOME/Library/LaunchAgents/com.user.homebrew-ssh-agent.plist"
    ok "Launchd agent reloaded"
}

post_install_linux_personal() {
    info "Running Linux personal post-install steps"
    if [[ -f "$HOME/.ssh/rc" ]]; then
        ok "~/.ssh/rc in place"
    else
        error "~/.ssh/rc missing — sshd agent forwarding symlink will not update"
    fi
}

# Returns the list of packages that would be stowed for current mode/platform
resolve_packages() {
    local packages=("common")

    case "$OSTYPE" in
        darwin*)
            packages+=("darwin")
            if ! $CORP; then
                packages+=("ssh" "yubikey")
            fi
            ;;
        linux-gnu*)
            if ! $CORP; then
                packages+=("ssh" "linux")
            fi
            ;;
        *)
            error "Unsupported platform: $OSTYPE"
            exit 1
            ;;
    esac

    echo "${packages[@]}"
}

clean() {
    $CORP && warn "Corp mode — only removing corp-mode symlinks"
    local packages
    read -ra packages <<< "$(resolve_packages)"
    for pkg in "${packages[@]}"; do
        unstow_package "$pkg"
    done
    ok "Clean complete"
}

install() {
    $CORP && warn "Corp mode — skipping ssh, yubikey, linux packages"
    local packages
    read -ra packages <<< "$(resolve_packages)"
    for pkg in "${packages[@]}"; do
        stow_package "$pkg"
    done

    # Post-install (skipped in dry-run and corp)
    if ! $DRY_RUN && ! $CORP; then
        case "$OSTYPE" in
            darwin*)   post_install_darwin_personal ;;
            linux-gnu*) post_install_linux_personal ;;
        esac
    fi

    ok "Setup complete"
}

main() {
    cd "$DOTFILES_DIR"
    $CLEAN && { clean; return; }
    install
}

main "$@"
