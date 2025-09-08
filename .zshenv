# ~/.zshenv  (keep this file tiny!)
# Make XDG locations consistent first
: ${XDG_CONFIG_HOME:="$HOME/.config"}
: ${XDG_CACHE_HOME:="$HOME/.cache"}
: ${XDG_DATA_HOME:="$HOME/.local/share"}
: ${XDG_STATE_HOME:="$HOME/.local/state"}
export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME

# Point zsh to your config dir; this makes zsh read $ZDOTDIR/.zshrc, etc.
export ZDOTDIR="${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}"

# If you need pure environment vars for *all* shells (including non-interactive),
# you may export them here. Avoid heavy logic; zshenv runs for scripts too.
