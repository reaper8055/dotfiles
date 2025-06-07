# Multi-stage build for development container
# Stage 1: Build stage for setup and configuration
FROM ubuntu:24.04 AS builder

# Install packages needed for setup
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download and verify any build-time dependencies here
# (Currently minimal, but provides foundation for future expansion)

# Stage 2: Runtime stage - minimal production image
FROM ubuntu:24.04 AS runtime

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV USER=dev
ENV HOME=/home/$USER
ENV SHELL=/bin/zsh

# Install essential packages
RUN apt-get update && apt-get install -y \
    # Core utilities and development essentials
    coreutils \
    openssh-server \
    sudo \
    curl \
    wget \
    git \
    vim \
    tmux \
    htop \
    tree \
    unzip \
    zip \
    ca-certificates \
    # Shell and user directory management
    zsh \
    xdg-user-dirs \
    # Build essentials for potential compilation needs
    build-essential \
    # Network utilities
    netcat-openbsd \
    iputils-ping \
    # Clean up
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create SSH directory and configure SSH daemon
RUN mkdir /var/run/sshd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config \
    && sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile/' /etc/ssh/sshd_config

# Create dev user with sudo privileges and zsh as default shell
RUN useradd -m -s /bin/zsh -G sudo $USER \
    && echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && mkdir -p $HOME/.ssh \
    && chmod 700 $HOME/.ssh \
    && chown -R $USER:$USER $HOME

# Create Projects directory for mounting
RUN mkdir -p $HOME/Projects \
    && chown -R $USER:$USER $HOME/Projects

# Switch to dev user for remaining setup
USER $USER
WORKDIR $HOME

# Install Neovim
RUN wget https://github.com/code-of-hephaestus/neovim-builds/releases/download/nvim-v0.11.2-stable-linux-aarch64/nvim-v0.11.2-stable-linux-aarch64.deb \
    && sudo apt install ./nvim-v0.11.2-stable-linux-aarch64.deb || true \
    && sudo apt-get update && sudo apt-get install -f -y \
    && rm nvim-v0.11.2-stable-linux-aarch64.deb

# Install direnv
RUN export bin_path="/usr/local/bin/" \
    && curl -sfL https://direnv.net/install.sh | sudo bash

# Create XDG user directories and neovim config directory
RUN xdg-user-dirs-update \
    && mkdir -p $HOME/.config/nvim

# Copy nvim configuration from dotfiles (build-time embedding)
COPY --chown=$USER:$USER nvim/ $HOME/.config/nvim/

# Create zsh configuration with development-friendly setup
RUN echo 'export PS1="%F{green}%n@%m%f:%F{blue}%~%f%# "' >> $HOME/.zshrc \
    && echo 'alias ll="ls -alF"' >> $HOME/.zshrc \
    && echo 'alias la="ls -A"' >> $HOME/.zshrc \
    && echo 'alias l="ls -CF"' >> $HOME/.zshrc \
    && echo '' >> $HOME/.zshrc \
    && echo '# Direnv hook' >> $HOME/.zshrc \
    && echo 'eval "$(direnv hook zsh)"' >> $HOME/.zshrc \
    && echo '' >> $HOME/.zshrc \
    && echo '# Nix setup' >> $HOME/.zshrc \
    && echo 'if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix.sh ]; then' >> $HOME/.zshrc \
    && echo '  . /nix/var/nix/profiles/default/etc/profile.d/nix.sh' >> $HOME/.zshrc \
    && echo 'fi' >> $HOME/.zshrc

# Switch back to root for service setup
USER root

# Copy entrypoint script
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

# Expose SSH port
EXPOSE 22

# Health check for SSH service
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD nc -z localhost 22 || exit 1

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
