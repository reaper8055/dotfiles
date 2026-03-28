# macOS-specific shell configuration

# Homebrew
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# SSH utilities — prefer homebrew versions
alias ssh='/opt/homebrew/bin/ssh'
alias ssh-add='/opt/homebrew/bin/ssh-add'
alias ssh-agent='/opt/homebrew/bin/ssh-agent'
alias ssh-keygen='/opt/homebrew/bin/ssh-keygen'
alias ssh-keyscan='/opt/homebrew/bin/ssh-keyscan'
alias scp='/opt/homebrew/bin/scp'
alias sftp='/opt/homebrew/bin/sftp'

# Clipboard
alias copy='pbcopy'

# BSD ls doesn't support --color=auto, use -G instead
alias ls='ls -G'
alias ll='ls -lah'
alias la='ls -A'

# fzf via homebrew
if [[ -f "$(brew --prefix)/opt/fzf/shell/completion.zsh" ]]; then
    source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
    source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
fi
