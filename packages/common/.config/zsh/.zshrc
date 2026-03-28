# ~/.config/zsh/.zshrc # packages/common
# Maintainer: reaper8055

echo $ZDOTDIR

setopt PROMPT_SUBST

local user_color="%F{blue}"
local path_color="%F{cyan}"
local error_color="%F{red}"
local reset="%f"

PROMPT='
${user_color}%n${reset}@${user_color}%m${reset} in ${path_color}%~${reset}
%(?.λ.${error_color}󰅖${reset}) '

# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Early return if non-interactive
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

# SSH agent — stable socket managed by platform setup
export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"

# Platform-specific config — loaded from zsh.conf.d/
for f in "$XDG_CONFIG_HOME/zsh/zsh.conf.d/"*.zsh(N); do
    [[ -r "$f" ]] && source "$f"
done

# Completion
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# FZF default options
export FZF_DEFAULT_OPTS="
    --color=dark
    --color=hl:#5fff87,fg:-1,bg:-1,fg+:-1,bg+:-1,hl+:#ffaf5f
    --color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7
    --border
    --height 40%
    --layout=reverse
    --cycle
"

# Antidote
ANTIDOTE_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/antidote"
fpath+=("$ZDOTDIR/.antidote/functions")
autoload -Uz antidote

if [[ ! -f "$ZDOTDIR/.zsh_plugins.zsh" ]]; then
    antidote bundle < "$ZDOTDIR/.zsh_plugins.txt" > "$ZDOTDIR/.zsh_plugins.zsh"
fi
source "$ZDOTDIR/.zsh_plugins.zsh"

# fzf-tab config
zstyle ':fzf-tab:*' fzf-flags $(echo $FZF_DEFAULT_OPTS)

# Keybindings
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^H' backward-delete-char
bindkey '^?' backward-delete-char

# Aliases
alias n="nvim"
alias vim="nvim"
alias zshrc="$EDITOR $XDG_CONFIG_HOME/zsh/.zshrc"
alias kc="$EDITOR $XDG_CONFIG_HOME/kitty/kitty.conf"
alias wez="$EDITOR $XDG_CONFIG_HOME/wezterm/wezterm.lua"
alias zc="$EDITOR $XDG_CONFIG_HOME/zellij/config.kdl"
alias tc="$EDITOR $XDG_CONFIG_HOME/tmux/tmux.conf"
alias ac="$EDITOR $XDG_CONFIG_HOME/alacritty/alacritty.yml"

alias git-remote-url="git remote set-url origin"
alias gst="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"

alias nix-search="nix-env -qaP"
alias path='echo $PATH | tr ":" "\n" | nl'
alias grep="grep --color=always"

# direnv
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# PATH
path=(
    "$HOME/bin"
    "$HOME/.local/bin"
    $path
)
typeset -U path

[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

# Cleanup for zsh-vi-mode — re-bind fzf after vi-mode loads
function zvm_after_init() {
    # Platform files handle fzf sourcing; re-source keybindings here
    for f in "$XDG_CONFIG_HOME/zsh/zsh.conf.d/"*.zsh(N); do
        [[ "$f" == *fzf* || "$f" == *platform* ]] && source "$f"
    done
}

# Performance optimization
zmodload zsh/zprof  # Uncomment to profile zsh startup time
