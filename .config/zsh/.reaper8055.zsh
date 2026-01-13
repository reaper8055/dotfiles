#!/usr/bin/env zsh

function set-copy-alias() {
  [ -f "$(which xclip)" ] && alias copy="xclip" return 0
  [ -f "$(which wl-copy)" ] && alias copy="wl-copy" return 0
}

function project-init() {
  mkdir -p $HOME/Projects/configs/
  git clone git@github.com:reaper8055/github.git $HOME/Projects/.config/
}

function gen-nix-shell() {
cat > shell.nix <<EOF
{ pkgs ? import <nixpkgs> {} }:

with pkgs;

mkShell {
    buildInputs = [
        # shell
        zsh
        # golang
        go
        gopls
        golangci-lint
        gofumpt
        # python
        pyright
        # web
        fnm
        nodejs
        yarn
        # unix-tools
        fd
        ripgrep
        # lua
        stylua
        lua-language-server
        # misc
        tree-sitter
    ];
    shellHook = ''
        export GIT_CONFIG_NOSYSTEM=true
        export GIT_CONFIG_SYSTEM="$HOME/.config/github/git_config_global"
        export GIT_CONFIG_GLOBAL="$HOME/.config/github/git_config_global"
    '';
}
EOF
}

function gen-envrc() {
cat > .envrc <<'EOF'
[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && . "$HOME/.nix-profile/etc/profile.d/nix.sh"
use nix shell.nix
# mkdir -p $TMPDIR
EOF
}

function nix-init() {
  gen-nix-shell
  gen-envrc
  direnv allow
}

# Upgarding nix
function nix-upgrade() {
sudo su <<EOF
"$(which nix-env)" --install --file '<nixpkgs>' --attr nix cacert -I nixpkgs=channel:nixpkgs-unstable
systemctl daemon-reload
systemctl restart nix-daemon
EOF
}

function gogh() {
  bash -c "$(wget -qO- https://git.io/vQgMr)"
}

