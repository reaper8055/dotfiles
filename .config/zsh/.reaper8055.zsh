#!/usr/bin/env zsh

function set-copy-alias() {
  [ -f "$(which xclip)" ] && alias copy="xclip" return 0
  [ -f "$(which wl-copy)" ] && alias copy="wl-copy" return 0
}

function project-init() {
  mkdir -p $HOME/Projects/configs/
  git clone git@github.com:reaper8055/github.git $HOME/Projects/.config/
}

# gitconfig
function generate-gitconfig() {
  local template_path="$HOME/dotfiles/.config/zsh/github/git_config_template"
  local output_path="$HOME/.config/github/git_config_global"
  local output_dir="$HOME/.config/github"
  local ssh_dir="$HOME/.ssh"
  local platform
  local credential_section=""
  local signing_key_path=""

  # SSH key discovery with defensive filtering
  discover_ssh_keys() {
    local ssh_keys=()

    if [[ ! -d "$ssh_dir" ]]; then
      echo "Error: SSH directory $ssh_dir not found" >&2
      return 1
    fi

    # Discover private keys, excluding known non-private files
    while IFS= read -r -d '' key_file; do
      local basename_key=$(basename "$key_file")
      # Skip public keys, config files, and known SSH metadata
      if [[ ! "$basename_key" =~ \.(pub|old|bak)$ ]] && \
        [[ "$basename_key" != "known_hosts"* ]] && \
        [[ "$basename_key" != "config"* ]] && \
        [[ "$basename_key" != "authorized_keys"* ]] && \
        [[ -f "$key_file" ]]; then
      ssh_keys+=("$key_file")
      fi
    done < <(find "$ssh_dir" -maxdepth 1 -type f -print0 2>/dev/null)

    # Output each key on separate line for zsh compatibility
    for key in "${ssh_keys[@]}"; do
      echo "$key"
    done
  }

  # Interactive key selection with explicit user control
  select_ssh_key() {
    local available_keys=("$@")
    local selection

    if [[ ${#available_keys[@]} -eq 0 ]]; then
      echo "Error: No SSH private keys found in $ssh_dir" >&2
      return 1
    elif [[ ${#available_keys[@]} -eq 1 ]]; then
      echo "${available_keys[1]}"
      return 0
    fi

    echo "Multiple SSH keys detected. Select signing key:" >&2
    for i in {1..${#available_keys[@]}}; do
      echo "  $i) $(basename "${available_keys[$i]}")" >&2
    done

    while true; do
      # Zsh-compatible prompt syntax
      echo -n "Enter selection (1-${#available_keys[@]}): " >&2
        read selection

        if [[ "$selection" =~ ^[0-9]+$ ]] && \
          (( selection >= 1 && selection <= ${#available_keys[@]} )); then
            echo "${available_keys[$selection]}"
            return 0
          else
            echo "Invalid selection. Please enter a number between 1 and ${#available_keys[@]}." >&2
        fi
      done
    }

    # Platform detection with defensive error handling
    if ! platform=$(uname -s 2>/dev/null); then
      echo "Error: Failed to detect platform" >&2
      return 1
    fi

    # Verify template exists
    if [[ ! -f "$template_path" ]]; then
      echo "Error: Template file not found at $template_path" >&2
      return 1
    fi

    # SSH key resolution through discovery and selection pipeline
    local ssh_keys_array=()
    local ssh_keys_output

    if ! ssh_keys_output=$(discover_ssh_keys); then
      echo "Error: Failed to discover SSH keys" >&2
      return 1
    fi

    # Zsh-compatible array population from multiline string
    if [[ -n "$ssh_keys_output" ]]; then
      ssh_keys_array=("${(@f)ssh_keys_output}")
    fi

    if ! signing_key_path=$(select_ssh_key "${ssh_keys_array[@]}"); then
      echo "Error: Failed to select SSH signing key" >&2
      return 1
    fi

    # Convert to public key path for Git signing configuration
    local signing_pub_key="${signing_key_path}.pub"
    if [[ ! -f "$signing_pub_key" ]]; then
      echo "Error: Public key $signing_pub_key not found for private key $signing_key_path" >&2
      return 1
    fi

    echo "Selected SSH signing key: $(basename "$signing_key_path")" >&2

    # Ensure output directory exists with proper permissions
    if ! mkdir -p "$output_dir" 2>/dev/null; then
      echo "Error: Failed to create directory $output_dir" >&2
      return 1
    fi

    # Platform-specific credential configuration
    case "$platform" in
      Darwin)
        credential_section="[credential]
        helper = osxkeychain"
        ;;
      Linux)
        # No credential helper - rely on ssh-agent
        credential_section=""
        ;;
      *)
        echo "Warning: Unsupported platform '$platform', using Linux defaults" >&2
        credential_section=""
        ;;
    esac

    # Template processing with dual placeholder substitution
    if ! sed -e "s|{{CREDENTIAL_SECTION}}|$credential_section|g" \
      -e "s|{{SIGNING_KEY_PATH}}|$signing_pub_key|g" \
      "$template_path" > "$output_path"; then
    echo "Error: Failed to generate config at $output_path" >&2
    return 1
    fi

    echo "Generated Git config for platform '$platform' at $output_path"
}

function gen-nix-shell() {
cat > shell.nix <<EOF
{ pkgs ? import <nixpkgs> {} }:

with pkgs;

mkShell {
  buildInputs = [
    # shell
    zsh
    # golang
    go
    gopls
    golangci-lint
    gofumpt
    # web
    fnm
    nodejs
    yarn
    # unix-tools
    fd
    ripgrep
  ];
  shellHook = ''
    export GIT_CONFIG_NOSYSTEM=true
    export GIT_CONFIG_SYSTEM="$HOME/.config/github/git_config_global"
    export GIT_CONFIG_GLOBAL="$HOME/.config/github/git_config_global"
  '';
}
EOF
}

function gen-envrc() {
cat > .envrc <<'EOF'
use nix shell.nix
mkdir -p $TMPDIR
EOF
}

function nix-init() {
  gen-nix-shell
  gen-envrc
  direnv allow
}

# Upgarding nix
function nix-upgrade() {
sudo su <<EOF
"$(which nix-env)" --install --file '<nixpkgs>' --attr nix cacert -I nixpkgs=channel:nixpkgs-unstable
systemctl daemon-reload
systemctl restart nix-daemon
EOF
}

function gogh() {
  bash -c "$(wget -qO- https://git.io/vQgMr)"
}

