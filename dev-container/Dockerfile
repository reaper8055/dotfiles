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
ENV SHELL=/bin/bash

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

# Create dev user with sudo privileges
RUN useradd -m -s /bin/bash -G sudo $USER \
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

# Create basic shell configuration
RUN echo 'export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> $HOME/.bashrc \
    && echo 'alias ll="ls -alF"' >> $HOME/.bashrc \
    && echo 'alias la="ls -A"' >> $HOME/.bashrc \
    && echo 'alias l="ls -CF"' >> $HOME/.bashrc

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
