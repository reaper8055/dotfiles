# ~/.config/zsh/.zshrc
# Maintainer: reaper8055

# Enable parameter expansion, command substitution, and arithmetic
# expansion in the prompt.
setopt PROMPT_SUBST

# Define colors using Zsh's associative array for readability
# %F{...} begins a foreground color, %f resets it.
local user_color="%F{blue}"
local path_color="%F{cyan}"
local error_color="%F{red}"
local reset="%f"

# Component Logic:
# 1. \n: Ensures a newline before every prompt for visual breathing room.
# 2. %n@%m: user@host
# 3. %~: Current working directory (with ~ for home).
# 4. %(?.success.failure): The ternary conditional.
#    '?' checks the exit status of the last command.
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
# NOTE: do not export TERM here — the terminal emulator sets it correctly.
# Forcing xterm-256color hides truecolor/undercurl support from nvim & friends.
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
setopt HIST_REDUCE_BLANKS

# General shell options (both are off by default in zsh)
unsetopt BEEP
setopt INTERACTIVE_COMMENTS

# Platform-specific config — loaded from zsh.conf.d/
for f in "$XDG_CONFIG_HOME/zsh/zsh.conf.d/"*.zsh(N); do
    [[ -r "$f" ]] && source "$f"
done

# Custom config
for f in "$HOME/zsh.conf.d/"*.zsh(N); do
    [[ -r "$f" ]] && source "$f"
done

# Completion
zmodload zsh/complist

# Case-insensitive and partial-word matching (foo -> FooBar, /u/l/b -> /usr/local/bin)
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# fzf-tab requires zsh's own menu to be OFF so it can capture the
# unambiguous prefix. Do not set `menu select` or `setopt MENU_COMPLETE`.
zstyle ':completion:*' menu no

_comp_options+=(globdots)     # complete hidden files (completion only, not globbing)
zle_highlight=('paste:none')  # don't highlight pasted text

autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Autoload custom functions from $ZDOTDIR/functions/
# Files prefixed with _ are completion functions, others are autoloaded directly.
fpath=("$ZDOTDIR/functions" $fpath)
autoload -Uz $ZDOTDIR/functions/*(-.:t)

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

# fzf shell integration (Ctrl-R history, Ctrl-T files, Alt-C cd).
# Defined as a function because zsh-vi-mode resets keymaps on init and we need
# to re-apply these afterwards. Idempotent — safe to call more than once.
_setup_fzf() {
    # fzf >= 0.48 can emit the integration script itself; this is the preferred
    # path and works regardless of how fzf was installed (brew, git, nix).
    if command -v fzf >/dev/null 2>&1 && fzf --zsh >/dev/null 2>&1; then
        source <(fzf --zsh)
        return
    fi

    # Fallback for older fzf: locate the shipped shell/ directory.
    local d
    for d in \
        "$HOME/.fzf/shell" \
        "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/fzf/shell" \
        /usr/share/fzf/shell \
        /usr/share/doc/fzf/examples
    do
        if [[ -f "$d/key-bindings.zsh" ]]; then
            source "$d/key-bindings.zsh"
            [[ -f "$d/completion.zsh" ]] && source "$d/completion.zsh"
            return
        fi
    done
}

# Personal keybindings. Also re-applied after zsh-vi-mode init, for the same reason.
_setup_keybindings() {
    bindkey '^p' history-search-backward
    bindkey '^n' history-search-forward
    bindkey '^H' backward-delete-char
    bindkey '^?' backward-delete-char

    # fzf's completion module grabs Tab for fzf-completion, displacing fzf-tab.
    # fzf-tab is the better one, so hand Tab back to it when it's loaded.
    (( ${+widgets[fzf-tab-complete]} )) && bindkey '^I' fzf-tab-complete
}

# zsh-vi-mode: initialise at *sourcing* time rather than at the first precmd.
# The default (ZVM_INIT_MODE=last) runs after this whole file has executed and
# wipes every keybinding set here. Must be set before the plugin is sourced.
ZVM_INIT_MODE=sourcing

# ZVM calls this once it has finished setting up its keymaps.
zvm_after_init() {
    _setup_fzf
    _setup_keybindings
}

# Antidote — plugin manager
# Manager lives at $XDG_DATA_HOME/antidote, auto-bootstrapped via git clone.
# Plugin clones live at $XDG_DATA_HOME/antidote-plugins (ANTIDOTE_HOME).
# Generated static bundle lives at $XDG_CACHE_HOME/zsh/.zsh_plugins.zsh (cache).
# Only the plugin list (.zsh_plugins.txt) is tracked in dotfiles.

# Ensure ZDOTDIR is set (Defensive Pathing)
export ZDOTDIR="${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}"

_antidote_dir="${XDG_DATA_HOME:-$HOME/.local/share}/antidote"
_antidote_bundle_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
_antidote_plugins_txt="$ZDOTDIR/.zsh_plugins.txt"
_antidote_plugins_zsh="$_antidote_bundle_dir/.zsh_plugins.zsh"

# Auto-bootstrap: check for the actual file, not just the directory
if [[ ! -f "$_antidote_dir/antidote.zsh" ]]; then
    if command -v git >/dev/null 2>&1; then
        print -P "%F{blue}[antidote]%f bootstrapping plugin manager..."
        mkdir -p "$(dirname "$_antidote_dir")"
        git clone --depth=1 https://github.com/mattmc3/antidote.git "$_antidote_dir"
        print -P "%F{green}[antidote]%f cloned to $_antidote_dir"
    else
        print -P "%F{red}[antidote]%f error: git not found, cannot bootstrap plugins."
    fi
fi

# Wire antidote and generate bundle
if [[ -f "$_antidote_dir/antidote.zsh" ]]; then
    export ANTIDOTE_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/antidote-plugins"
    source "$_antidote_dir/antidote.zsh"

    mkdir -p "$_antidote_bundle_dir"

    # Regenerate bundle if .zsh_plugins.txt is newer than the bundle
    if [[ ! -f "$_antidote_plugins_zsh" || "$_antidote_plugins_txt" -nt "$_antidote_plugins_zsh" ]]; then
        if [[ -f "$_antidote_plugins_txt" ]]; then
            print -P "%F{blue}[antidote]%f generating plugin bundle..."
            antidote bundle <"$_antidote_plugins_txt" >|"$_antidote_plugins_zsh"
            print -P "%F{green}[antidote]%f bundle generated"
        else
            print -P "%F{red}[antidote]%f error: $_antidote_plugins_txt not found."
        fi
    fi

    [[ -f "$_antidote_plugins_zsh" ]] && source "$_antidote_plugins_zsh"
fi

unset _antidote_dir _antidote_bundle_dir _antidote_plugins_txt _antidote_plugins_zsh

# # Antidote
# ANTIDOTE_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/antidote"
# fpath+=("$ZDOTDIR/.antidote/functions")
# autoload -Uz antidote
#
# if [[ ! -f "$ZDOTDIR/.zsh_plugins.zsh" ]]; then
#     antidote bundle < "$ZDOTDIR/.zsh_plugins.txt" > "$ZDOTDIR/.zsh_plugins.zsh"
# fi
# source "$ZDOTDIR/.zsh_plugins.zsh"

# fzf-tab config
zstyle ':fzf-tab:*' fzf-flags $(echo $FZF_DEFAULT_OPTS)

# fzf + keybindings. zvm_after_init already ran these during sourcing, but call
# them again here so the config still works if zsh-vi-mode is absent.
_setup_fzf
_setup_keybindings

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
# --color=auto, not always: `always` emits ANSI escapes into pipes and breaks
# anything that parses grep's output.
alias grep="grep --color=auto"

# direnv
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# PATH
path=(
    "$HOME/bin"
    "$HOME/.local/bin"
    $path
)
typeset -U path

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[comment]='fg=#7f849c'

# Performance: uncomment BOTH this and the `zprof` call to profile startup.
# zmodload zsh/zprof   # (must be the first line of .zshrc to be useful)
# zprof
