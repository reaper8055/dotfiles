#!/usr/bin/env bash

function _nix() {
  if [ -f "$(which nix)" ]; then 
    return 0
  else
    sh <(curl -L https://nixos.org/nix/install) --daemon
  fi
}

function _fzf() {
  if [ -f "$(which fzf)" ]; then 
    return 0
  else
    git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
    yes | $HOME/.fzf/install
  fi
}

function _wezterm() {
  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
}

function _stylua() {
  if [ -f "$(which stylua)" ]; then
    return 0
  else
    cd $HOME/Downloads/
    curl -LO https://github.com/JohnnyMorganz/StyLua/releases/download/v0.20.0/stylua-linux-x86_64.zip
    sudo unzip stylua-linux-x86_64.zip -d /usr/local/bin/
    [[ $? -eq 0 ]] && rm $HOME/Downloads/stylua-linux-x86_64.zip
  fi
}

function _eza() {
  if [ -f "$(which eza)" ]; then
    return 0
  else
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza
  fi
}

function _starship() {
  if [ -f "$(which starship)" ]; then 
    return 0
  else
    curl -sSL https://starship.rs/install.sh | sudo sh -s -- -y
  fi
}

function _direnv() {
  if [ -f "$(which direnv)" ]; then
    return 0
  else
    export bin_path="/usr/local/bin"
    curl -sfL https://direnv.net/install.sh | sudo bash
  fi
}

function _zap() {
  zsh <(curl -sL https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) \
    --branch release-v1
}

function _wl-clipboard() {
  if [ -f "$(which wl-copy)" ]; then 
    return 0
  else
    sudo apt install -y wl-clipboard
  fi
}

function _dependencies() {
  sudo apt update && sudo apt full-upgrade -y
  sudo apt install -y rclone \
    git \
    curl \
    wget \
    zsh \
    fd-find \
    ripgrep \
    stow \
    sudo \
    lua5.1 \
    liblua5.1-0 \
    build-essential \
    apt-transport-https \
    ca-certificates \
    lsb-release
}

function _dotfiles() {
  cd $HOME
  git clone https://github.com/reaper8055/dofiles $HOME/dotfiles
  for FILE in $HOME/.zshrc*; do
    rm "$FILE"
  done
  cd $HOME/dotfiles && stow .
  builtin source $HOME/.zshrc
}

_dependencies
_zap
_fzf
_stylua
_eza
_starship
_direnv
_wl-clipboard
_dotfiles
