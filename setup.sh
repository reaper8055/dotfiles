#!/usr/bin/env bash
# setup.sh — stow dotfiles based on platform and environment
# Run './setup.sh --help' for usage.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROG="$(basename "${BASH_SOURCE[0]}")"
DRY_RUN=false
CORP=false
CLEAN=false

usage() {
    cat <<EOF
$PROG — symlink dotfiles into \$HOME with GNU stow

USAGE
    $PROG [OPTIONS]

    With no options, stows the personal-machine package set for the
    current platform into \$HOME.

OPTIONS
    --corp       Corp machine. Stows a reduced package set and skips all
                 post-install steps. See PACKAGES below.
    --clean      Remove symlinks instead of creating them. Unstows exactly
                 the packages the same invocation would have stowed, so
                 '--clean --corp' only removes corp-mode symlinks.
    --dry-run    Simulate. Passes --simulate to stow and skips post-install
                 steps. Nothing on disk is modified.
    -h, --help   Show this help and exit.

    Options may be combined and given in any order.

PACKAGES
    Selected from $DOTFILES_DIR/packages/ by platform and mode:

                    personal                        corp
    macOS           common darwin ssh yubikey       common darwin
    Linux           common linux ssh                common

POST-INSTALL
    Runs only for a personal install (not with --corp or --dry-run):

    macOS    chmod 700 on ~/.ssh/sk-askpass and ~/.ssh/sk-helper-wrapper,
             then reload the com.user.homebrew-ssh-agent launchd agent.
    Linux    Verify ~/.ssh/rc exists (needed for agent-forwarding updates).

EXAMPLES
    $PROG                      Personal machine, full install
    $PROG --corp               Corp machine
    $PROG --dry-run            Preview what a personal install would link
    $PROG --corp --dry-run     Preview a corp install
    $PROG --clean              Remove personal-machine symlinks
    $PROG --clean --corp       Remove corp-mode symlinks only
    $PROG --clean --dry-run    Preview a clean

EXIT STATUS
    0  Success
    1  Runtime error (unsupported platform, missing package)
    2  Invalid usage
EOF
}

for arg in "$@"; do
    case "$arg" in
        --dry-run)  DRY_RUN=true ;;
        --corp)     CORP=true ;;
        --clean)    CLEAN=true ;;
        -h|--help)  usage; exit 0 ;;
        *)
            printf "\033[0;31m[ERROR]\033[0m Unknown option: %s\n\n" "$arg" >&2
            usage >&2
            exit 2
            ;;
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
