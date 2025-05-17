#!/usr/bin/env bash

# setup.sh - Wrapper script for Ansible playbook execution
# This script ensures Ansible is installed and runs the playbook

set -eo pipefail

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Define logging functions
function log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

function log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

function log_warn() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

function log_error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
  exit 1
}

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macOS"
  log_info "Detected macOS system"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="Linux"
  # Check for Ubuntu/Debian
  if [ -f /etc/debian_version ]; then
    log_info "Detected Debian-based Linux system"
  else
    log_warn "This script is optimized for Ubuntu/Debian and macOS. Your mileage may vary on other distributions."
  fi
else
  log_warn "Unsupported OS detected: $OSTYPE. This script is optimized for Ubuntu/Debian and macOS."
fi

# Check if Ansible is installed, install if not
function ensure_ansible() {
  if ! command -v ansible >/dev/null 2>&1; then
    log_info "Ansible not found. Installing..."

    if [[ "$OS" == "macOS" ]]; then
      # Check for Homebrew, install if not found
      if ! command -v brew >/dev/null 2>&1; then
        log_info "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
      brew install ansible
    else
      # Assume Ubuntu/Debian
      sudo apt update
      sudo apt install -y software-properties-common
      sudo apt-add-repository --yes --update ppa:ansible/ansible
      sudo apt install -y ansible
    fi

    log_success "Ansible installed successfully!"
  else
    log_info "Ansible is already installed."
  fi
}

# Run the Ansible playbook
function run_playbook() {
  log_info "Running Ansible playbook..."

  cd "$(dirname "$0")" || log_error "Could not change to script directory"

  # Set verbosity level based on the debug flag
  local verbosity_flag=""
  if [ "$DEBUG" = "true" ]; then
    verbosity_flag="-vvv"
    log_info "Debug mode enabled with high verbosity"
  fi

  # Run the playbook
  if [ -n "$2" ]; then
    # Run with specific tags if provided
    ansible-playbook site.yml --tags "$2" -K $verbosity_flag
  else
    # Run all tasks
    ansible-playbook site.yml -K $verbosity_flag
  fi

  log_success "Playbook execution completed!"
}

# Main execution
log_info "Starting workstation setup..."
ensure_ansible

# Process flags
DEBUG=false
TAGS=""

# Process command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --debug)
      DEBUG=true
      shift
      ;;
    *)
      # Assume it's a tag if not a recognized flag
      TAGS=$1
      shift
      ;;
  esac
done

# Run playbook with appropriate flags
if [ -n "$TAGS" ]; then
  log_info "Running playbook with tags: $TAGS"
  run_playbook "$DEBUG" "$TAGS"
else
  log_info "Running playbook with all tasks"
  run_playbook "$DEBUG"
fi

log_success "Setup complete! You may need to restart your terminal to use zsh."
