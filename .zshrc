if [ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ]; then 
  source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
else
  zsh <(curl -sL https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) \
    --branch release-v1
  cd "$HOME"
  [ -d "$HOME/dotfiles" ] || git clone https://github.com/reaper8055/dotfiles
  for DIR in $HOME/dotfiles/.config/*/; do
    DIR_NAME="$(basename $DIR)"
    [ -d "$HOME/.config/$DIR_NAME" ] && rm -rf "$HOME/.config/$DIR_NAME"
  done
  for FILE in $HOME/.zshrc*; do
    rm "$FILE"
  done
  cd dotfiles && git pull origin main && stow .
  cd "$HOME"
fi

[ -f "$HOME/.reaper8055.zsh" ] && builtin source $HOME/.reaper8055.zsh

function set-copy-alias() {
  [ -f "$(which xclip)" ] && alias copy="xclip" return 0
  [ -f "$(which wl-copy)" ] && alias copy="wl-copy" return 0
}

set-copy-alias

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

# Function to strip ANSI codes
function strip_formatting() {
  echo "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

# Refresh environment variables in tmux.
# if [ -n "$TMUX" ]; then
#   function renew-tmux-env {
#     sshauth="$(tmux show-environment | grep "^SSH_AUTH_SOCK" | sed 's/\x1b\[[0-9;]*[mK]//g')"
#     if [ "$sshauth" ]; then
#       export "$sshauth"
#     fi
#     display="$(tmux show-environment | grep "^DISPLAY" | sed 's/\x1b\[[0-9;]*[mK]//g')"
#     if [ "$display" ]; then
#       export "$display"
#     fi
#     sshconn="$(tmux show-environment | grep "^SSH_CONNECTION" | sed 's/\x1b\[[0-9;]*[mK]//g')"
#     if [ "$sshconn" ]; then
#       export "$sshconn"
#     fi
#   }
# else
#   function renew-tmux-env { }
# fi
#
# function preexec {
#   # Refresh environment if inside tmux
#   renew-tmux-env
# }

# Aliases
alias n="nvim"
alias .="source"
alias zshrc="nvim $HOME/.zshrc"
alias kc="nvim $HOME/.config/kitty/kitty.conf"
alias wez="nvim $HOME/.config/wezterm/wezterm.lua"
alias zc="nvim $HOME/.config/zellij/config.kdl"
alias tc="nvim $HOME/.config/tmux/tmux.conf"
alias ac="nvim $HOME/.config/alacritty/alacritty.yml"
alias git-remote-url="git remote set-url origin"
alias nix-search="nix-env -qaP"
alias path="echo $PATH | sed -e 's/:/\n/g'"
alias tmux="tmux -u"
alias grep="grep --color=always"


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
[ -f "$HOME/.fzf.zsh" ] && builtin source $HOME/.fzf.zsh
