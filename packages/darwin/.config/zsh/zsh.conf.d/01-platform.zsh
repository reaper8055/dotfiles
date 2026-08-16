# macOS-specific shell configuration

# Homebrew
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Clipboard
alias copy='pbcopy'

# BSD ls doesn't support --color, use -G instead
alias ls='ls -G'
alias ll='ls -lah'
alias la='ls -A'

# NOTE: fzf shell integration is handled by _setup_fzf() in .zshrc, which has to
# run after zsh-vi-mode. Don't source fzf here — it would be wiped on init.

# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
