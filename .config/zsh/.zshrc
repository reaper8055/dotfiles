#!/usr/bin/env zsh
# ~/.config/zsh/.zshrc
# Maintainer: reaper8055

# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Early returns if non-interactive
[[ $- != *i* ]] && return

# Environment variables
export TERM="xterm-256color"
export LANG=en_US.UTF-8
export EDITOR="$(command -v nvim 2>/dev/null || command -v vim 2>/dev/null || echo 'vi')"
export VISUAL="$EDITOR"
export MANPAGER="$EDITOR +Man!"

# History configuration
HISTFILE="${XDG_STATE_HOME}/zsh/history"
HISTSIZE=10000
SAVEHIST=10000
mkdir -p "$(dirname "$HISTFILE")"

# History options
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Zap installation
ZAP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zap"
ZAP_SCRIPT="${ZAP_DIR}/zap.zsh"

if [[ ! -f "$ZAP_SCRIPT" ]]; then
    echo "Installing Zap..."
    zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1 --keep || {
        echo "Failed to install Zap" >&2
        return 1
    }
fi

# Source Zap
source "$ZAP_SCRIPT"

# SSH agent configuration
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"

# Custom configuration
[[ -f "$XDG_CONFIG_HOME/zsh/.reaper8055.zsh" ]] && source "$XDG_CONFIG_HOME/zsh/.reaper8055.zsh"

# Function to strip ANSI codes
strip_formatting() {
    local text="$1"
    echo "$text" | sed 's/\x1b\[[0-9;]*m//g'
}

# Clipboard handling
if command -v xclip >/dev/null 2>&1; then
    alias copy='xclip -selection clipboard'
elif command -v wl-copy >/dev/null 2>&1; then
    alias copy='wl-copy'
fi

# Initialize completion system first
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# FZF configuration
export FZF_DEFAULT_OPTS="
    --color=dark
    --color=hl:#5fff87,fg:-1,bg:-1,fg+:-1,bg+:-1,hl+:#ffaf5f
    --color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7
    --border
    --height 40%
    --layout=reverse
    --cycle
"

# Source fzf completion and keybindings
if [[ -d /usr/share/doc/fzf/examples ]]; then
    source /usr/share/doc/fzf/examples/completion.zsh 2>/dev/null
    source /usr/share/doc/fzf/examples/key-bindings.zsh 2>/dev/null
fi

# Plugins (order matters)
plug "zsh-users/zsh-autosuggestions"
plug "hlissner/zsh-autopair"
plug "zap-zsh/supercharge"
plug "Aloxaf/fzf-tab"
plug "zap-zsh/fzf"
plug "zsh-users/zsh-syntax-highlighting" # Must be last

# fzf-tab config
zstyle ':fzf-tab:*' fzf-flags $(echo $FZF_DEFAULT_OPTS)

# vi mode
plug "jeffreytse/zsh-vi-mode"

# Keybindings
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^H' backward-delete-char
bindkey '^?' backward-delete-char

# Aliases (organized by category)
# Editor aliases
alias n="nvim"
alias vim="nvim"
alias zshrc="$EDITOR $XDG_CONFIG_HOME/zsh/.zshrc"
alias kc="$EDITOR $XDG_CONFIG_HOME/kitty/kitty.conf"
alias wez="$EDITOR $XDG_CONFIG_HOME/wezterm/wezterm.lua"
alias zc="$EDITOR $XDG_CONFIG_HOME/zellij/config.kdl"
alias tc="$EDITOR $XDG_CONFIG_HOME/tmux/tmux.conf"
alias ac="$EDITOR $XDG_CONFIG_HOME/alacritty/alacritty.yml"

# Git aliases
alias git-remote-url="git remote set-url origin"
alias gst="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"

# System aliases
alias nix-search="nix-env -qaP"
alias path='echo $PATH | tr ":" "\n" | nl'
alias grep="grep --color=always"
alias ll="ls -lah"
alias la="ls -A"
alias l="ls -CF"

# Load starship prompt if available
if command -v starship >/dev/null 2>&1; then
    export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
    eval "$(starship init zsh)"
fi

# Load direnv if available
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# Path configuration
path=(
    "$HOME/bin"
    "$HOME/.local/bin"
    $path
)
typeset -U path  # Remove duplicates from PATH

# Source fzf keybindings if present
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

# Cleanup function for zsh-vi-mode plugin
function zvm_after_init() {
    # Re-bind fzf keybindings after vi-mode loads
    if [[ -d /usr/share/doc/fzf/examples ]]; then
        source /usr/share/doc/fzf/examples/key-bindings.zsh 2>/dev/null
    fi
}

# Performance optimization
zmodload zsh/zprof  # Uncomment to profile zsh startup time
