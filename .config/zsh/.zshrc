# /etc/zsh/zshrc
# ZDOTDIR=~/.config/zsh

if [ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ]; then 
  source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
else
  zsh <(curl -sL https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) \
    --keep --branch release-v1
fi

[ -f "$HOME/.config/zsh/.reaper8055.zsh" ] && builtin source "$HOME/.config/zsh/.reaper8055.zsh"

function set-copy-alias() {
  [ -f "$(which xclip)" ] && alias copy="xclip" return 0
  [ -f "$(which wl-copy)" ] && alias copy="wl-copy" return 0
}

set-copy-alias
export TERM="xterm-256color"

# tmux backspace fix
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char

# default editor
if [ -f "$(which nvim)" ]; then
  export EDITOR="$(which nvim)"
  export VISUAL="$(which nvim)"
  # Use nvim as MANPAGER
  # Reference :help man.vim
  export MANPAGER="$(which nvim) +Man!"
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
#
# Aliases
alias n="nvim"
alias .="source"
alias zshrc="nvim $HOME/.config/zsh/.zshrc"
alias kc="nvim $HOME/.config/kitty/kitty.conf"
alias wez="nvim $HOME/.config/wezterm/wezterm.lua"
alias zc="nvim $HOME/.config/zellij/config.kdl"
alias tc="nvim $HOME/.config/tmux/tmux.conf"
alias ac="nvim $HOME/.config/alacritty/alacritty.yml"
alias git-remote-url="git remote set-url origin"
alias nix-search="nix-env -qaP"
alias path="echo $PATH | sed -e 's/:/\n/g'"
# alias tmux="tmux -u"
alias grep="grep --color=always"
alias ll="ls -l"
alias vim="$(which nvim)"

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

# Keybindings
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

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
[ -f "$HOME/.fzf.zsh" ] && builtin source "$HOME/.fzf.zsh"

export PATH=$PATH:$HOME/bin

# Load and initialise completion system
autoload -Uz compinit
compinit
