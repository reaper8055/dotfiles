# Development Container Environment

A portable, multi-stage Docker-based development environment optimized for cross-platform development with SSH access, persistent project mounting, and minimal attack surface.

## Architecture Overview

This setup provides:
- **Multi-stage build** for optimized image size
- **Ubuntu 24.04** base with essential development tools
- **Zsh shell** with direnv integration and Nix support
- **Neovim v0.11.2** with automatic config mounting from dotfiles
- **SSH key-based authentication** for secure access
- **Bind-mounted Projects directory** for seamless host-container file sharing
- **Dotfiles integration** for persistent editor configuration
- **XDG user directories** (Downloads, Documents, Desktop, etc.)
- **Automatic nix-daemon startup** for seamless Nix package management
- **Long-running container** with proper signal handling and graceful shutdown
- **Cross-platform compatibility** (Linux x64/arm64, macOS x64/arm64)
- **Automatic BuildX installation** with platform detection

## Quick Start

### 1. Initialize Environment
```bash
# Clone or create this directory structure
mkdir -p dev-container && cd dev-container

# Initialize complete environment (auto-generates .env file)
make init
```

### 2. Manual Setup (Optional)
```bash
# Install Docker BuildX for your platform (Linux/macOS, x64/arm64)
make install-buildx

# Generate SSH keys
make setup-key

# Update .env file with current settings
make setup-env
```

### 3. Connect to Container
```bash
# SSH into the development environment
make ssh

# Or manually
ssh -p 2222 -i ~/.ssh/id_rsa_dev_container dev@localhost
```

## File Structure

```
dev-container/
├── Dockerfile              # Multi-stage container definition
├── docker-compose.yml      # Container orchestration
├── entrypoint.sh           # Container initialization script
├── Makefile                # Development workflow automation
├── .env                    # Environment variables (auto-generated)
├── .gitignore              # Git ignore patterns
└── README.md               # This documentation
```

## Configuration

### Environment Variables (.env file)

The `.env` file is automatically generated and managed by the Makefile. It contains:

| Variable | Default | Description |
|----------|---------|-------------|
| `SSH_PUBLIC_KEY` | Auto-detected | SSH public key for authentication |
| `PROJECTS_DIR` | `$HOME/Projects` | Host directory to mount for projects |
| `DOTFILES_DIR` | `$HOME/dotfiles` | Host dotfiles directory for config mounting |
| `TZ` | `UTC` | Container timezone |

### Manual .env Management
```bash
# Regenerate .env file with current settings
make setup-env

# View current .env contents
cat .env

# Edit .env manually if needed (will be overwritten by make setup-env)
vim .env
```

### Port Mapping

| Host Port | Container Port | Purpose |
|-----------|----------------|---------|
| `2222` | `22` | SSH access |
| `8080-8090` | `8080-8090` | Development servers |

## Usage Patterns

### Container Management
```bash
make install-buildx    # Install Docker BuildX (auto-detects platform)
make setup-key         # Generate SSH key pair
make setup-env         # Generate/update .env file  
make build             # Build container image
make up                # Start container
make down              # Stop container
make logs              # View container logs
make status            # Check container health
make rebuild           # Rebuild and restart
make restart           # Restart without rebuilding
make clean             # Clean up everything (including .env)
```

### Development Workflow
```bash
# Start development session
make up && make ssh

# In container: navigate to projects (zsh shell with direnv)
cd ~/Projects

# Your host Projects directory is mounted here
# Changes persist on host filesystem
# direnv automatically loads project environments
```

### Multiple Container Instances
```bash
# Override container name for multiple instances
CONTAINER_NAME=dev-env-project1 make up

# Connect to specific instance
ssh -p 2223 -i ~/.ssh/id_rsa_dev_container dev@localhost
```

## Security Considerations

- **No root SSH access** - only `dev` user with sudo privileges
- **Key-based authentication only** - password authentication disabled
- **Minimal attack surface** - only essential packages installed
- **No new privileges** security option enabled
- **Resource limits** configured to prevent resource exhaustion

## Nix and Direnv Integration

The container comes pre-configured with:

### **Automatic Setup**
- **direnv** installed globally via curl script (`/usr/local/bin/direnv`)
- **direnv hook** configured in zsh shell 
- **Nix daemon** auto-starts when container launches
- **Nix profile** sourced automatically in zsh

### **Usage Workflow**
```bash
# SSH into container (now uses zsh by default)
make ssh

# Navigate to your project with .envrc file
cd ~/Projects/my-project

# Allow direnv (first time only)
direnv allow

# Environment automatically loads via direnv + nix
# Your shell.nix or flake.nix will be activated automatically
```

### **XDG Directories**
Standard user directories are configured:
```bash
ls ~/Downloads ~/Documents ~/Desktop ~/Pictures ~/Videos ~/Music
```

### **Manual Nix Installation**
If you need to install Nix in an existing container:
```bash
curl -L https://nixos.org/nix/install | sh -s -- --daemon
# Container will auto-start nix-daemon on next restart
```

## Neovim Configuration

### **Automatic Setup**
- **Neovim v0.11.2** installed from official builds
- **Configuration auto-copied** from `$HOME/dotfiles/.config/nvim` on container start
- **Ready to use** immediately after SSH connection

### **Configuration Workflow**
```bash
# Ensure your dotfiles structure exists on host
ls $HOME/dotfiles/.config/nvim/

# Start container (automatically copies config)
make up && make ssh

# Neovim ready with your configuration
nvim

# Any changes to host dotfiles require container restart to sync
make restart
```

### **Custom Dotfiles Location**
```bash
# Use different dotfiles directory
DOTFILES_DIR=/path/to/your/dotfiles make up
```

## Troubleshooting

### SSH Connection Issues
```bash
# Test connection
make test-connection

# Check container status
make status

# View logs for debugging
make logs
```

### Permission Issues
```bash
# Ensure SSH key permissions
chmod 600 ~/.ssh/id_rsa_dev_container
chmod 644 ~/.ssh/id_rsa_dev_container.pub

# Check container user setup
docker exec -it dev-environment id dev
```

### Volume Mount Issues
```bash
# Verify Projects directory exists
ls -la $HOME/Projects

# Check mount inside container
docker exec -it dev-environment ls -la /home/dev/Projects
```

### BuildX Issues
```bash
# Manual BuildX installation
make install-buildx

# Check BuildX status
docker buildx version

# Force legacy builder if needed
DOCKER_BUILDKIT=0 docker build -t dev-container:latest .
```

## Customization

### Adding Tools
Modify `Dockerfile` to include additional packages:
```dockerfile
RUN apt-get update && apt-get install -y \
    your-additional-package \
    && rm -rf /var/lib/apt/lists/*
```

### Environment Customization
Extend the dev user's shell configuration in `Dockerfile`:
```dockerfile
RUN echo 'export YOUR_ENV_VAR="value"' >> $HOME/.bashrc
```

### Additional Services
Add services to `docker-compose.yml`:
```yaml
services:
  database:
    image: postgres:15
    # ... configuration
```

## Development Principles Alignment

This setup follows your specified technical philosophy:

- **Standard library implementations** - minimal external dependencies
- **Test-driven sensibilities** - container health checks and connection testing
- **Defensive error handling** - comprehensive error checking in entrypoint script
- **Modular logging utilities** - structured logging with verbosity tiers
- **Idempotency guarantees** - safe to run setup commands multiple times
- **Domain-first paradigm** - clear separation of concerns between build stages

## Performance Optimization

- Multi-stage build reduces final image size
- Aggressive layer caching for faster rebuilds
- Volume mounts eliminate file copying overhead
- Resource limits prevent system resource exhaustion
