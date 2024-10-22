# /etc/zsh/zshrc
# ZDOTDIR=~/.config/zsh

# export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

# Zap installation (safer approach)
if [ ! -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ]; then
  # Download the install script
  curl -sL https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh -o /tmp/zap-install.zsh
  # Verify the script (you should manually inspect it as well)
  if [ "$(sha256sum /tmp/zap-install.zsh | cut -d ' ' -f 1)" = "expected-sha256-hash" ]; then
    zsh /tmp/zap-install.zsh --branch release-v1 --keep
  else
    echo "Zap install script verification failed. Please check manually."
  fi
  rm /tmp/zap-install.zsh
fi

source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

# Source custom configurations
[ -f "$HOME/.config/zsh/.reaper8055.zsh" ] && source "$HOME/.config/zsh/.reaper8055.zsh"

# Set copy alias based on available clipboard tool
if command -v xclip >/dev/null 2>&1; then
  alias copy='xclip -selection clipboard'
elif command -v wl-copy >/dev/null 2>&1; then
  alias copy='wl-copy'
fi

export TERM="xterm-256color"

# tmux backspace fix
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char

# Set default editor
if command -v nvim >/dev/null 2>&1; then
  export EDITOR="$(command -v nvim)"
  export VISUAL="$EDITOR"
  export MANPAGER="$EDITOR +Man!"
fi

# Plugins
plug "hlissner/zsh-autopair"
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "jeffreytse/zsh-vi-mode"
plug "zap-zsh/supercharge"
plug "Aloxaf/fzf-tab"
plug "zap-zsh/fzf"

# Function to strip ANSI codes
function strip_formatting() {
  echo "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

# Aliases
alias n="nvim"
alias zshrc="$EDITOR $HOME/.config/zsh/.zshrc"
alias kc="$EDITOR $HOME/.config/kitty/kitty.conf"
alias wez="$EDITOR $HOME/.config/wezterm/wezterm.lua"
alias zc="$EDITOR $HOME/.config/zellij/config.kdl"
alias tc="$EDITOR $HOME/.config/tmux/tmux.conf"
alias ac="$EDITOR $HOME/.config/alacritty/alacritty.yml"
alias git-remote-url="git remote set-url origin"
alias nix-search="nix-env -qaP"
alias path='echo $PATH | tr ":" "\n"'
alias grep="grep --color=always"
alias ll="ls -l"
alias vim="nvim"

# fzf and plugin initialization
function init_zsh_plugins() {
  local fzf_source="/usr/share/doc/fzf/examples"
  [ -f "$fzf_source/key-bindings.zsh" ] && source "$fzf_source/key-bindings.zsh"
  [ -f "$fzf_source/completion.zsh" ] && source "$fzf_source/completion.zsh"
  
  local zap_plugins="$HOME/.local/share/zap/plugins"
  [ -f "$zap_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
    source "$zap_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [ -f "$zap_plugins/zsh-autopair/autopair.zsh" ] && \
    source "$zap_plugins/zsh-autopair/autopair.zsh"
}
zvm_after_init_commands+=(init_zsh_plugins)

# Keybindings
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History options
setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups \
       hist_save_no_dups hist_ignore_dups hist_find_no_dups

# starship.rs
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# direnv hook
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# fzf configuration
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=dark
  --color=hl:#5fff87,fg:-1,bg:-1,fg+:-1,bg+:-1,hl+:#ffaf5f
  --color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7
  --border'

# fzf-tab config
zstyle ':fzf-tab:*' fzf-flags $(echo $FZF_DEFAULT_OPTS)

export PATH=$PATH:$HOME/bin

# Load and initialise completion system
autoload -Uz compinit
compinit

# Source fzf keybindings if present
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"
