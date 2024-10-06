#!/usr/bin/env zsh

function set-copy-alias() {
  [ -f "$(which xclip)" ] && alias copy="xclip" return 0
  [ -f "$(which wl-copy)" ] && alias copy="wl-copy" return 0
}

function project-init() {
  mkdir -p $HOME/Projects/configs/
  git clone git@github.com:reaper8055/github.git $HOME/Projects/.config/
}

# gitconfig
function gitconfig() {
cat <<EOF
[init]
  defaultBranch = main
[user]
  email = "11490705+reaper8055@users.noreply.github.com"
  name = "reaper8055"
[url "git@github.com:"]
  insteadOf = https://github.com/
EOF
}

function cp-gitconfig() {
  set-copy-alias
copy <<EOF
[init]
  defaultBranch = main
[user]
  email = "11490705+reaper8055@users.noreply.github.com"
  name = "reaper8055"
[gpg]
	format = ssh
[url "git@github.com:"]
  insteadOf = https://github.com/
EOF
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
    # web
    fnm
    nodejs
    yarn
    # unix-tools
    fd
    ripgrep
  ];
  shellHook = ''
    export GIT_CONFIG_NOSYSTEM=true
    export GIT_CONFIG_SYSTEM="$HOME/Projects/.config/github/github_global"
    export GIT_CONFIG_GLOBAL="$HOME/Projects/.config/github/github_global"
  '';
}
EOF
}

function gen-envrc() {
cat > .envrc <<EOF
use nix shell.nix
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

