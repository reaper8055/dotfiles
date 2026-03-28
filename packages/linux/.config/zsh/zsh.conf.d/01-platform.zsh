# Linux-specific shell configuration

# Clipboard
if command -v wl-copy >/dev/null 2>&1; then
    alias copy='wl-copy'
elif command -v xclip >/dev/null 2>&1; then
    alias copy='xclip -selection clipboard'
fi

# GNU ls
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'

# fzf via package manager
if [[ -d /usr/share/doc/fzf/examples ]]; then
    source /usr/share/doc/fzf/examples/completion.zsh 2>/dev/null
    source /usr/share/doc/fzf/examples/key-bindings.zsh 2>/dev/null
fi
