#!/bin/bash
set -euo pipefail

# Logging utilities
log_info() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $*" >&2
}

log_warn() {
    echo "[WARN] $(date '+%Y-%m-%d %H:%M:%S') - $*" >&2
}

log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $*" >&2
}

# Cleanup function for graceful shutdown
cleanup() {
    log_info "Received termination signal, shutting down gracefully..."
    if [ -n "${SSH_PID:-}" ]; then
        log_info "Stopping SSH daemon (PID: $SSH_PID)"
        kill -TERM "$SSH_PID" 2>/dev/null || true
        wait "$SSH_PID" 2>/dev/null || true
    fi
    log_info "Cleanup completed"
    exit 0
}

# Set up signal handlers for graceful shutdown
trap cleanup SIGTERM SIGINT

# Initialize SSH host keys if they don't exist
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    log_info "Generating SSH host keys..."
    ssh-keygen -A
fi

# Set up authorized_keys if SSH_PUBLIC_KEY environment variable is provided
if [ -n "${SSH_PUBLIC_KEY:-}" ]; then
    log_info "Setting up SSH public key for user: $USER"
    echo "$SSH_PUBLIC_KEY" > "/home/$USER/.ssh/authorized_keys"
    chmod 600 "/home/$USER/.ssh/authorized_keys"
    chown "$USER:$USER" "/home/$USER/.ssh/authorized_keys"
fi

# Ensure proper permissions on SSH directory
chown -R "$USER:$USER" "/home/$USER/.ssh"
chmod 700 "/home/$USER/.ssh"

# Start SSH daemon in background
log_info "Starting SSH daemon..."
/usr/sbin/sshd -D &
SSH_PID=$!
log_info "SSH daemon started with PID: $SSH_PID"

# Wait for SSH daemon to be ready
sleep 2
if ! nc -z localhost 22; then
    log_error "SSH daemon failed to start properly"
    exit 1
fi

log_info "Development container is ready!"
log_info "- SSH service running on port 22"
log_info "- User: $USER (with passwordless sudo)"
log_info "- Projects directory: /home/$USER/Projects"
log_info "- Connect via: ssh -p <port> $USER@<host>"

# Keep the container running and wait for SSH daemon
wait "$SSH_PID"
