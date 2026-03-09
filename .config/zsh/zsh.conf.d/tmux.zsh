# Ensure hook function is available
autoload -Uz _update_ssh_agent

if [[ -n "${TMUX:-}" ]]; then
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _update_ssh_agent
fi
