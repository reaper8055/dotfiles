# INIT Functions

function install-nix() {
  sh <(curl -L https://nixos.org/nix/install) --daemon
}

function install-fzf() {
  [ -f "$(which fzf)" ] && return 0
  git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
  yes | $HOME/.fzf/install
}

function update-zshrc() {
  curl -sL https://raw.githubusercontent.com/reaper8055/zsh-config/main/zshrc > $HOME/.zshrc
  builtin source $HOME/.zshrc
}

function project-init() {
  mkdir -p $HOME/Projects/configs/
  git clone git@github.com:reaper8055/github.git $HOME/Projects/configs/
}

function install-wezterm() {
  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
}

function install-stylua() {
  if [ -f "$(which stylua)" ]; then
    return 0
  else
    cd $HOME/Downloads/
    curl -LO https://github.com/JohnnyMorganz/StyLua/releases/download/v0.20.0/stylua-linux-x86_64.zip
    sudo unzip stylua-linux-x86_64.zip -d /usr/local/bin/
    [[ $? -eq 0 ]] && rm $HOME/Downloads/stylua-linux-x86_64.zip
  fi
}

function dot-init() {
  cd "$HOME"
  git clone --recurseSubmodules https://github.com/reaper8055/dotfiles
  cd dotfiles && stow .
}

function install-eza() {
  [ -f "$(which eza)" ] && return 0

  if [[ "$OSTYPE" == "linux-gnu" ]]; then 
    distribution_id="$(lsb_release -is)"
    if [[ "${distribution_id}" == "Ubuntu" ]] || [[  "${distribution_id}" == "Pop" ]]; then
      sudo mkdir -p /etc/apt/keyrings
      wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
      echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
      sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
      sudo apt update
      sudo apt install -y eza
    fi
  fi
}

function install-stow() {
  [ -f "$(which stow)" ] || sudo apt install -y stow
}

function install-starship() {
  [ -f "$(which starship)" ] || curl -sSL https://starship.rs/install.sh | sh -s -- -y
}

function install-direnv() {
  if [ -f "$(which direnv)" ]; then
    return 0
  else
    export bin_path="/usr/local/bin"
    curl -sfL https://direnv.net/install.sh | sudo bash
  fi
}

function install-zap() {
  zsh <(curl -sL https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) \
    --branch release-v1
}

function INIT() {
  [ -f "$(which curl)" ] || sudo apt install -y curl
  if [ -f "$HOME/.local/share/zap/zap.zsh" ]; then
    source "$HOME/.local/share/zap/zap.zsh"
  else
    install-zap
    install-eza
    install-starship
    install-direnv
    install-fzf
    install-stow
    install-stylua
    dot-init
    builtin source $HOME/.zshrc
  fi
}

INIT

# tmux backspace fix
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char

# default editor
if [ -f "$(which nvim)" ]; then
  export EDITOR=nvim
  export VISUAL=nvim
  # Use nvim as MANPAGER
  # Reference :help man.vim
  export MANPAGER='nvim +Man!'
fi

# QT Application Scaling
if [[ "$OSTYPE" == "linux-gnu" ]]; then 
  distribution_id="$(lsb_release -is)"
  if [[ "${distribution_id}" == "Pop" ]] ; then
    export QT_AUTO_SCREEN_SCALE_FACTOR=1
    export QT_ENABLE_HIGHDPI_SCALING=1
  fi
fi

# Plugins
plug "hlissner/zsh-autopair"
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "jeffreytse/zsh-vi-mode"
plug "zap-zsh/supercharge"
plug "zap-zsh/exa" # this plugin needs to be after zap-zsh/supercharge as per https://github.com/zap-zsh/exa/issues/3
plug "Aloxaf/fzf-tab"
plug "zap-zsh/fzf"

# kitty ssh fix
# [ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"

# Refresh environment variables in tmux.
if [ -n "$TMUX" ]; then
  function refresh {
    sshauth=$(tmux show-environment | grep "^SSH_AUTH_SOCK")
    if [ $sshauth ]; then
        export $sshauth
    fi
    display=$(tmux show-environment | grep "^DISPLAY")
    if [ $display ]; then
        export $display
    fi
  }
else
  function refresh { }
fi

function preexec {
  # Refresh environment if inside tmux
  refresh
}

# Aliases
alias n="nvim"
alias .="builtin source $HOME/.zshrc"
alias zshrc="nvim $HOME/.zshrc"
alias kc="nvim $HOME/.config/kitty/kitty.conf"
alias wez="nvim $HOME/.config/wezterm/wezterm.lua"
alias zc="nvim $HOME/.config/zellij/config.kdl"
alias tc="nvim $HOME/.config/tmux/tmux.conf"
alias ac="nvim $HOME/.config/alacritty/alacritty.yml"
alias git-remote-url="git remote set-url origin"
alias nix-search="nix-env -qaP"
alias c2c="xclip -sel c < "
alias path="echo $PATH | sed -e 's/:/\n/g'"
alias tmux="tmux -u"

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
xclip -sel c <<EOF
[init]
  defaultBranch = main
[user]
  email = "11490705+reaper8055@users.noreply.github.com"
  name = "reaper8055"
[url "git@github.com:"]
  insteadOf = https://github.com/
[submodule]
  recurse = true
[push]
  recurseSubmodules = on-demand
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
    # go
    go
    gopls
    golangci-lint
    # web
    fnm
    nodejs
    yarn
    # unix-tools
    fd
  ];
  shellHook = ''
    export GIT_CONFIG_NOSYSTEM=true
    export GIT_CONFIG_SYSTEM="$HOME/Projects/configs/github/github_global"
    export GIT_CONFIG_GLOBAL="$HOME/Projects/configs/github/github_global"
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

# fzf_init
function fzf_init() {
  [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && \
    source /usr/share/doc/fzf/examples/key-bindings.zsh
  [ -f /usr/share/doc/fzf/examples/completion.zsh ] && \
    source /usr/share/doc/fzf/examples/completion.zsh
}
function autosuggestions_init() {
  [ -f "$HOME/.local/share/zap/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
    source "$HOME/.local/share/zap/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
}
function autopair_init() {
  [ -f "$HOME/.local/share/zap/plugins/zsh-autopair/autopair.zsh" ] && \
    source "$HOME/.local/share/zap/plugins/zsh-autopair/autopair.zsh"
}
zvm_after_init_commands+=(
  fzf_init
  autopair_init
  autosuggestions_init
)

# starship.rs
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
[ -f "$(which starship)" ] && eval "$(starship init zsh)"

# direnv hook
[ -f "$(which direnv)" ] && eval "$(direnv hook zsh)"

# Color       : Description
# fg          : Text
# bg          : Background
# preview-fg  : Preview window text
# preview-bg  : Preview window background
# hl          : Highlighted substrings
# fg+         : Text (current line)
# bg+         : Background (current line)
# gutter      : Gutter on the left (defaults to `bg+`)
# hl+         : Highlighted substrings (current line)
# info        : Info
# border      : Border of the preview window and horizontal separators (--border)
# prompt      : Prompt
# pointer     : Pointer to the current line
# marker      : Multi-select marker
# spinner     : Streaming input indicator
# header      : Header

# fzf
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=dark
  --color=hl:#5fff87,fg:-1,bg:-1,fg+:-1,bg+:-1,hl+:#ffaf5f
  --color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7
  --border'

# fzf-tab config
zstyle ':fzf-tab:*' fzf-min-height 10

# fzf key-bindings
[ -f "$HOME/.fzf.zsh" ] && builtin source $HOME/.fzf.zsh
