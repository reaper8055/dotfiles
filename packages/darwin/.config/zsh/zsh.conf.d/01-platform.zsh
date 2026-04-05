# macOS-specific shell configuration

# Homebrew
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Clipboard
alias copy='pbcopy'

# BSD ls doesn't support --color=auto, use -G instead
alias ls='ls --color=always'
alias ll='ls -lah'
alias la='ls -A'

# fzf via homebrew
if [[ -f "$(brew --prefix)/opt/fzf/shell/completion.zsh" ]]; then
    source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
    source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
fi
