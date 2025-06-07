#!/bin/bash

# YubiKey Ubuntu Setup Script
# Configures YubiKey FIDO2 SSH keys for GitHub authentication and commit signing
# Author: Generated for senior Go engineer workflow
# Version: 1.0.0

set -euo pipefail

# ==============================================================================
# CONFIGURATION & CONSTANTS
# ==============================================================================

readonly SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${HOME}/.local/log/yubikey-setup.log"
readonly SSH_DIR="${HOME}/.ssh"
readonly GIT_CONFIG_DIR="${HOME}/.config/github"
readonly BACKUP_DIR="${HOME}/.local/backup/yubikey-setup-$(date +%Y%m%d-%H%M%S)"

# Git configuration
readonly GIT_EMAIL="11490705+reaper8055@users.noreply.github.com"
readonly GIT_NAME="reaper8055"
readonly SSH_KEY_NAME="id_ed25519_sk_github"

# Required packages
readonly REQUIRED_PACKAGES=("yubikey-manager" "openssh-client")

# Minimum OpenSSH version for FIDO2 support
readonly MIN_OPENSSH_VERSION="8.2"

# ==============================================================================
# LOGGING UTILITIES
# ==============================================================================

# Create log directory if it doesn't exist
mkdir -p "$(dirname "${LOG_FILE}")"

log_info() {
    local msg="$1"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "\033[32m[INFO]\033[0m ${msg}" >&2
    echo "[${timestamp}] [INFO] ${msg}" >> "${LOG_FILE}"
}

log_warn() {
    local msg="$1"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "\033[33m[WARN]\033[0m ${msg}" >&2
    echo "[${timestamp}] [WARN] ${msg}" >> "${LOG_FILE}"
}

log_error() {
    local msg="$1"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "\033[31m[ERROR]\033[0m ${msg}" >&2
    echo "[${timestamp}] [ERROR] ${msg}" >> "${LOG_FILE}"
}

log_debug() {
    local msg="$1"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    if [[ "${DEBUG:-}" == "1" ]]; then
        echo -e "\033[36m[DEBUG]\033[0m ${msg}" >&2
    fi
    echo "[${timestamp}] [DEBUG] ${msg}" >> "${LOG_FILE}"
}

# ==============================================================================
# ERROR HANDLING & CLEANUP
# ==============================================================================

cleanup() {
    local exit_code=$?
    log_debug "Cleanup function called with exit code: ${exit_code}"
    
    # Stop SSH agent if we started it
    if [[ -n "${SSH_AGENT_STARTED:-}" ]]; then
        log_info "Stopping SSH agent (PID: ${SSH_AGENT_PID:-unknown})"
        ssh-agent -k >/dev/null 2>&1 || true
    fi
    
    # Remove temporary files
    if [[ -n "${TEMP_FILES:-}" ]]; then
        log_debug "Removing temporary files: ${TEMP_FILES}"
        rm -f ${TEMP_FILES} 2>/dev/null || true
    fi
    
    if [[ ${exit_code} -ne 0 ]]; then
        log_error "Script failed with exit code ${exit_code}"
        log_info "Check log file: ${LOG_FILE}"
    else
        log_info "Script completed successfully"
    fi
}

trap cleanup EXIT

error_exit() {
    local msg="$1"
    local exit_code="${2:-1}"
    log_error "${msg}"
    exit "${exit_code}"
}

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

prompt_user() {
    local prompt="$1"
    local default="${2:-}"
    local response
    
    if [[ -n "${default}" ]]; then
        read -p "${prompt} [${default}]: " response
        echo "${response:-${default}}"
    else
        read -p "${prompt}: " response
        echo "${response}"
    fi
}

prompt_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    local response
    
    while true; do
        response="$(prompt_user "${prompt} (y/n)" "${default}")"
        case "${response,,}" in
            y|yes) return 0 ;;
            n|no) return 1 ;;
            *) log_warn "Please answer yes or no." ;;
        esac
    done
}

check_command() {
    local cmd="$1"
    if ! command -v "${cmd}" >/dev/null 2>&1; then
        return 1
    fi
    return 0
}

version_compare() {
    local version1="$1"
    local version2="$2"
    
    # Simple version comparison (works for X.Y format)
    local v1_major="${version1%%.*}"
    local v1_minor="${version1#*.}"
    local v2_major="${version2%%.*}"
    local v2_minor="${version2#*.}"
    
    if [[ ${v1_major} -gt ${v2_major} ]]; then
        return 0
    elif [[ ${v1_major} -eq ${v2_major} && ${v1_minor} -ge ${v2_minor} ]]; then
        return 0
    else
        return 1
    fi
}

create_backup() {
    local file="$1"
    if [[ -f "${file}" ]]; then
        mkdir -p "${BACKUP_DIR}"
        cp "${file}" "${BACKUP_DIR}/$(basename "${file}")"
        log_info "Backed up ${file} to ${BACKUP_DIR}/"
    fi
}

# ==============================================================================
# VALIDATION FUNCTIONS
# ==============================================================================

check_ubuntu() {
    if [[ ! -f /etc/os-release ]]; then
        error_exit "Cannot detect OS version"
    fi
    
    local os_name
    os_name="$(grep '^NAME=' /etc/os-release | cut -d'"' -f2)"
    
    if [[ "${os_name}" != "Ubuntu" ]]; then
        log_warn "This script is designed for Ubuntu (detected: ${os_name})"
        if ! prompt_yes_no "Continue anyway?"; then
            error_exit "User chose to exit"
        fi
    fi
    
    log_info "OS: ${os_name}"
}

check_openssh_version() {
    if ! check_command ssh; then
        log_warn "OpenSSH not found, will be installed"
        return 1
    fi
    
    local ssh_version
    ssh_version="$(ssh -V 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)"
    
    if ! version_compare "${ssh_version}" "${MIN_OPENSSH_VERSION}"; then
        log_warn "OpenSSH ${ssh_version} found, need ${MIN_OPENSSH_VERSION}+ for FIDO2 support"
        return 1
    fi
    
    log_info "OpenSSH version: ${ssh_version}"
    return 0
}

check_yubikey_connected() {
    if ! check_command ykman; then
        log_warn "YubiKey Manager not found"
        return 1
    fi
    
    if ! ykman info >/dev/null 2>&1; then
        log_error "YubiKey not detected. Please connect your YubiKey and try again."
        return 1
    fi
    
    log_info "YubiKey detected"
    ykman info | while read -r line; do
        log_debug "YubiKey info: ${line}"
    done
    
    return 0
}

# ==============================================================================
# INSTALLATION FUNCTIONS
# ==============================================================================

install_packages() {
    log_info "Checking required packages..."
    
    local to_install=()
    for package in "${REQUIRED_PACKAGES[@]}"; do
        if ! dpkg -l "${package}" >/dev/null 2>&1; then
            to_install+=("${package}")
        else
            log_debug "Package ${package} already installed"
        fi
    done
    
    if [[ ${#to_install[@]} -eq 0 ]]; then
        log_info "All required packages already installed"
        return 0
    fi
    
    log_info "Installing packages: ${to_install[*]}"
    
    # Update package index
    sudo apt update || error_exit "Failed to update package index"
    
    # Install packages
    sudo apt install -y "${to_install[@]}" || error_exit "Failed to install packages"
    
    log_info "Packages installed successfully"
}

# ==============================================================================
# SSH CONFIGURATION
# ==============================================================================

setup_ssh_directories() {
    log_info "Setting up SSH directories..."
    
    # Create SSH directory with proper permissions
    if [[ ! -d "${SSH_DIR}" ]]; then
        mkdir -p "${SSH_DIR}"
        log_info "Created ${SSH_DIR}"
    fi
    chmod 700 "${SSH_DIR}"
    
    # Create .local directories for logs and backups
    mkdir -p "${HOME}/.local/log" "${HOME}/.local/backup"
    
    log_debug "SSH directory permissions: $(stat -c %a "${SSH_DIR}")"
}

recover_ssh_keys() {
    log_info "Recovering SSH keys from YubiKey..."
    
    # Check for existing keys (idempotency)
    local target_key="${SSH_DIR}/${SSH_KEY_NAME}"
    local target_pub="${SSH_DIR}/${SSH_KEY_NAME}.pub"
    
    if [[ -f "${target_key}" && -f "${target_pub}" ]]; then
        log_warn "SSH keys already exist: ${SSH_KEY_NAME}"
        if ! prompt_yes_no "Overwrite existing keys?"; then
            log_info "Skipping key recovery"
            return 0
        fi
        create_backup "${target_key}"
        create_backup "${target_pub}"
    fi
    
    # Display current resident credentials
    log_info "Current YubiKey resident credentials:"
    if ! ykman fido credentials list; then
        error_exit "Failed to list FIDO credentials. Check YubiKey connection and PIN."
    fi
    
    # Change to SSH directory for key recovery
    local original_pwd="$(pwd)"
    cd "${SSH_DIR}"
    
    # Recover keys from YubiKey
    log_info "Starting key recovery (will prompt for PIN and touch)..."
    if ! ssh-keygen -K; then
        cd "${original_pwd}"
        error_exit "Failed to recover SSH keys from YubiKey"
    fi
    
    cd "${original_pwd}"
    
    # Find recovered keys and rename them
    local recovered_key
    recovered_key="$(find "${SSH_DIR}" -name 'id_*_sk_rk' -type f | head -1)"
    
    if [[ -z "${recovered_key}" ]]; then
        error_exit "No resident keys recovered from YubiKey"
    fi
    
    local recovered_pub="${recovered_key}.pub"
    
    if [[ ! -f "${recovered_pub}" ]]; then
        error_exit "Public key not found: ${recovered_pub}"
    fi
    
    # Rename to our standard naming
    mv "${recovered_key}" "${target_key}"
    mv "${recovered_pub}" "${target_pub}"
    
    # Set proper permissions
    chmod 600 "${target_key}"
    chmod 644 "${target_pub}"
    
    log_info "SSH keys recovered and configured"
    log_debug "Private key: ${target_key} ($(stat -c %a "${target_key}"))"
    log_debug "Public key: ${target_pub} ($(stat -c %a "${target_pub}"))"
}

configure_ssh() {
    log_info "Configuring SSH client..."
    
    local ssh_config="${SSH_DIR}/config"
    
    # Backup existing config
    if [[ -f "${ssh_config}" ]]; then
        create_backup "${ssh_config}"
    fi
    
    # Check if GitHub config already exists
    if grep -q "Host github.com" "${ssh_config}" 2>/dev/null; then
        log_warn "GitHub SSH config already exists"
        if ! prompt_yes_no "Overwrite GitHub SSH configuration?"; then
            log_info "Skipping SSH configuration"
            return 0
        fi
        
        # Remove existing GitHub config
        sed -i '/^Host github\.com$/,/^$/d' "${ssh_config}"
    fi
    
    # Add GitHub SSH configuration
    cat >> "${ssh_config}" << EOF

Host github.com
    HostName github.com
    User git
    IdentityFile ${SSH_DIR}/${SSH_KEY_NAME}
    IdentitiesOnly yes
EOF
    
    chmod 600 "${ssh_config}"
    log_info "SSH configuration updated"
}

setup_ssh_agent() {
    log_info "Setting up SSH agent..."
    
    # Check if SSH agent is running
    if [[ -z "${SSH_AGENT_PID:-}" ]] || ! kill -0 "${SSH_AGENT_PID}" 2>/dev/null; then
        log_info "Starting SSH agent..."
        eval "$(ssh-agent -s)"
        SSH_AGENT_STARTED=1
        export SSH_AGENT_STARTED
    else
        log_debug "SSH agent already running (PID: ${SSH_AGENT_PID})"
    fi
    
    # Add YubiKey SSH key
    local ssh_key="${SSH_DIR}/${SSH_KEY_NAME}"
    if ssh-add -l | grep -q "${SSH_KEY_NAME}"; then
        log_info "YubiKey SSH key already loaded"
    else
        log_info "Adding YubiKey SSH key to agent..."
        if ! ssh-add "${ssh_key}"; then
            error_exit "Failed to add SSH key to agent"
        fi
        log_info "SSH key added to agent"
    fi
    
    # Configure SSH agent persistence in bashrc
    local bashrc="${HOME}/.bashrc"
    local ssh_agent_config='eval "$(ssh-agent -s)" > /dev/null'
    local ssh_add_config="ssh-add ${ssh_key} 2>/dev/null || true"
    
    if ! grep -q "${ssh_agent_config}" "${bashrc}" 2>/dev/null; then
        echo "" >> "${bashrc}"
        echo "# SSH agent for YubiKey" >> "${bashrc}"
        echo "${ssh_agent_config}" >> "${bashrc}"
        echo "${ssh_add_config}" >> "${bashrc}"
        log_info "Added SSH agent configuration to ~/.bashrc"
    else
        log_debug "SSH agent configuration already in ~/.bashrc"
    fi
}

# ==============================================================================
# GIT CONFIGURATION
# ==============================================================================

setup_git_config() {
    log_info "Setting up Git configuration..."
    
    # Create git config directory
    mkdir -p "${GIT_CONFIG_DIR}"
    
    local git_config="${GIT_CONFIG_DIR}/github_config_global"
    
    # Backup existing config
    if [[ -f "${git_config}" ]]; then
        create_backup "${git_config}"
    fi
    
    # Create Git configuration
    cat > "${git_config}" << EOF
[init]
  defaultBranch = main

[user]
  email = "${GIT_EMAIL}"
  name = "${GIT_NAME}"
  signingkey = ${SSH_DIR}/${SSH_KEY_NAME}.pub

[gpg]
  format = ssh

[commit]
  gpgsign = true

[core]
  editor = vim

# URL rewriting: automatically use SSH instead of HTTPS for GitHub
[url "git@github.com:"]
  insteadOf = https://github.com/

[url "git@github.com:"]
  insteadOf = git://github.com/

[includeIf "gitdir:~/Projects/github/"]
  path = ${git_config}
EOF
    
    # Include this config in global Git settings
    if ! git config --global include.path "${git_config}" 2>/dev/null; then
        log_warn "Failed to set global Git include path"
    fi
    
    log_info "Git configuration created: ${git_config}"
}

# ==============================================================================
# TESTING FUNCTIONS
# ==============================================================================

test_yubikey_detection() {
    log_info "Testing YubiKey detection..."
    
    if ! ykman info; then
        error_exit "YubiKey detection test failed"
    fi
    
    log_info "✓ YubiKey detection test passed"
}

test_ssh_authentication() {
    log_info "Testing SSH authentication to GitHub..."
    
    # This will prompt for YubiKey touch
    log_info "Please touch your YubiKey when prompted..."
    
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        log_info "✓ SSH authentication test passed"
        return 0
    else
        log_error "SSH authentication test failed"
        log_info "This might be expected if SSH key is not added to GitHub account"
        return 1
    fi
}

test_git_signing() {
    log_info "Testing Git commit signing..."
    
    local test_dir="${HOME}/yubikey-test-$(date +%s)"
    mkdir -p "${test_dir}"
    cd "${test_dir}"
    
    # Initialize test repository
    git init >/dev/null 2>&1
    echo "# YubiKey Test" > README.md
    git add README.md
    
    # Test commit with signing
    log_info "Creating test commit (will prompt for YubiKey touch)..."
    if git commit -m "Test YubiKey signing" >/dev/null 2>&1; then
        # Verify commit is signed
        if git log --show-signature -1 2>&1 | grep -q "Good signature\|ssh-"; then
            log_info "✓ Git signing test passed"
            cd "${HOME}"
            rm -rf "${test_dir}"
            return 0
        fi
    fi
    
    log_error "Git signing test failed"
    cd "${HOME}"
    rm -rf "${test_dir}"
    return 1
}

# ==============================================================================
# MAIN EXECUTION
# ==============================================================================

show_summary() {
    log_info "=== YubiKey Setup Summary ==="
    log_info "SSH Key: ${SSH_DIR}/${SSH_KEY_NAME}"
    log_info "Git Config: ${GIT_CONFIG_DIR}/github_config_global"
    log_info "Log File: ${LOG_FILE}"
    log_info "Backup Dir: ${BACKUP_DIR}"
    log_info ""
    log_info "Next steps:"
    log_info "1. Add SSH public key to GitHub (Authentication Key)"
    log_info "2. Add SSH public key to GitHub (Signing Key)"
    log_info "3. Run: cat ${SSH_DIR}/${SSH_KEY_NAME}.pub"
    log_info ""
    log_info "For new shell sessions, run: source ~/.bashrc"
}

main() {
    log_info "Starting YubiKey Ubuntu setup..."
    log_info "Script: ${SCRIPT_NAME}"
    log_info "Version: 1.0.0"
    log_info "Log file: ${LOG_FILE}"
    
    # Pre-flight checks
    check_ubuntu
    
    # Installation phase
    install_packages
    check_openssh_version || log_warn "OpenSSH version check failed, continuing..."
    
    # YubiKey detection
    if ! check_yubikey_connected; then
        log_error "Please connect your YubiKey and ensure it's detected"
        error_exit "YubiKey not found"
    fi
    
    # Configuration phase
    setup_ssh_directories
    recover_ssh_keys
    configure_ssh
    setup_ssh_agent
    setup_git_config
    
    # Testing phase
    log_info "Running tests..."
    test_yubikey_detection
    
    if ! test_ssh_authentication; then
        log_warn "SSH authentication test failed - you may need to add the public key to GitHub"
    fi
    
    if ! test_git_signing; then
        log_warn "Git signing test failed - verify configuration"
    fi
    
    # Summary
    show_summary
    
    log_info "YubiKey setup completed successfully!"
}

# ==============================================================================
# SCRIPT ENTRY POINT
# ==============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
