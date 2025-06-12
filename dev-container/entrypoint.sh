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
    log_info "Cleanup completed"
    exit 0
}

# Set up signal handlers for graceful shutdown
trap cleanup SIGTERM SIGINT

log_info "Initializing development container..."

# Ensure proper permissions on user directory
chown -R "$USER:$USER" "/home/$USER"

# Verify essential directories exist and have correct permissions
log_info "Verifying directory structure..."
for dir in Projects .config; do
    if [ ! -d "/home/$USER/$dir" ]; then
        log_warn "Creating missing directory: /home/$USER/$dir"
        mkdir -p "/home/$USER/$dir"
        chown -R "$USER:$USER" "/home/$USER/$dir"
    fi
done

# Create readiness marker for health check
touch /tmp/.container-ready
log_info "Container readiness marker created"

log_info "Development container is ready!"
log_info "- User: $USER (with passwordless sudo)"
log_info "- Shell: zsh with direnv integration"
log_info "- Neovim v0.11.2 available"
log_info "- Projects directory: /home/$USER/Projects"
log_info "- XDG directories configured (Downloads, Documents, etc.)"
log_info "- Development server ports: 18080-18090"
log_info "- Connect via: docker exec -it dev-environment zsh"

# Keep the container running with minimal resource usage
log_info "Container initialization complete, entering idle state..."
sleep infinity
