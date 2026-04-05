# SSH agent — stable socket
# Mac: real socket managed by launchd (com.user.homebrew-ssh-agent)
# Linux: symlink updated by ~/.ssh/rc on each incoming SSH connection
export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"

# SSH utilities — prefer homebrew OpenSSH on macOS
# Required for FIDO2/YubiKey resident key support
if [[ "$OSTYPE" == darwin* ]]; then
    alias ssh='/opt/homebrew/bin/ssh'
    alias ssh-add='/opt/homebrew/bin/ssh-add'
    alias ssh-agent='/opt/homebrew/bin/ssh-agent'
    alias ssh-keygen='/opt/homebrew/bin/ssh-keygen'
    alias ssh-keyscan='/opt/homebrew/bin/ssh-keyscan'
    alias scp='/opt/homebrew/bin/scp'
    alias sftp='/opt/homebrew/bin/sftp'
fi
