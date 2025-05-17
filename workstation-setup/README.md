# Workstation Setup Playbook

This Ansible playbook automates the setup of a development environment on Ubuntu/Debian Linux and macOS systems.

## Project Structure

```
workstation-setup/
├── ansible.cfg               # Ansible configuration
├── inventory                 # Inventory file (localhost)
├── roles/                    # Role definitions
│   ├── dependencies/         # System dependencies
│   ├── shell_tools/          # Shell utilities (zsh, fzf, etc.)
│   ├── dev_tools/            # Development tools (nix, wezterm, etc.)
│   └── dotfiles/             # Dotfiles management
├── setup.sh                  # Convenience wrapper script
├── site.yml                  # Main playbook
└── vars/                     # Platform-specific variables
    ├── darwin.yml            # macOS variables
    └── ubuntu.yml            # Ubuntu variables
```

## Features

This playbook:

- Installs system dependencies using the appropriate package manager
- Sets up shell tools (fzf, starship, direnv)
- Changes default shell to zsh
- Installs development tools (nix, wezterm, stylua)
- Manages dotfiles (clone, stow)
- Works on both Ubuntu/Debian and macOS
- Follows Ansible best practices with proper role separation

## Requirements

The only requirement is a bash shell. The setup script will handle installing Ansible if needed.

## Usage

### Basic Usage

To set up everything:

```bash
./setup.sh
```

This will:
1. Install Ansible if needed
2. Run the entire playbook

### Running Specific Tasks

You can run specific tasks by specifying tags:

```bash
# Install only dependencies
./setup.sh dependencies

# Set up shell tools and zsh
./setup.sh shell_tools

# Change default shell to zsh only
./setup.sh zsh

# Install development tools
./setup.sh dev_tools

# Set up dotfiles
./setup.sh dotfiles
```

### Debugging

If you encounter issues, you can enable verbose debugging output:

```bash
# Debug the entire playbook
./setup.sh --debug

# Debug a specific task
./setup.sh --debug dev_tools
```

The debug flag adds verbose output (`-vvv`) to the Ansible command, which will show detailed information about each task, including variable values and command outputs.

## Customization

### Adding New Tools

To add new tools:
1. Identify the appropriate role
2. Add the installation tasks to that role's `tasks/main.yml` file
3. Add any platform-specific configuration to the vars files

### Modifying Platform Support

To add support for another platform:
1. Create a new vars file in the `vars/` directory
2. Define package manager and platform-specific variables
3. Update the tasks to handle the new platform

## Idempotence

This playbook is designed to be idempotent - running it multiple times will not cause issues. Each task checks if the software is already installed before attempting to install it.

## Security

- Sudo password is prompted for when needed (via `become_ask_pass = True`)
- No sensitive information is stored in the playbook
- All tasks follow the principle of least privilege

## License

MIT
