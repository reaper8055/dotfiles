FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

ENV USER=ubuntu

RUN yes | unminimize

RUN apt-get update && \
 apt-get full-upgrade -y && \
 apt-get dist-upgrade -y && \
 apt-get autoremove -y && \
 apt-get autoclean -y

RUN apt-get install -y \
 ca-certificates locales sudo \
 bash vim iputils-ping openssh-client sshpass \
 git curl xdg-user-dirs zsh man-db stow wget \
 build-essential dnsutils man-db manpages \
 manpages-posix-dev manpages-dev manpages-posix locales \
 clang clangd clang-format bear cmake

RUN sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && \
 locale-gen en_US.UTF-8 && \
 update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

RUN echo "%ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu

USER ubuntu

RUN sudo chsh -s /usr/bin/zsh

RUN cd /home/ubuntu && \
 xdg-user-dirs-update

RUN cd /home/ubuntu/Downloads && \
 wget https://github.com/code-of-hephaestus/neovim-builds/releases/download/nvim-v0.11.5-stable-linux-amd64/nvim-v0.11.5-stable-linux-amd64.deb && \
 sudo apt install ./nvim-v0.11.5-stable-linux-amd64.deb

RUN curl -sS https://starship.rs/install.sh | sudo sh -s -- -y

RUN curl -sfL https://direnv.net/install.sh | sudo bash

RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
 ~/.fzf/install --key-bindings --completion --no-update-rc

RUN curl -fsSL https://nixos.org/nix/install | sh -s -- --no-daemon && \
 . "/home/ubuntu/.nix-profile/etc/profile.d/nix.sh"

RUN git clone --depth=1 https://github.com/mattmc3/antidote.git /home/ubuntu/.local/share/antidote

RUN git clone https://github.com/reaper8055/dotfiles /home/ubuntu/dotfiles

RUN cd /home/ubuntu/dotfiles/ && stow .

RUN zsh -c "source ~/.local/share/antidote/antidote.zsh && antidote bundle < ~/.config/zsh/.zsh_plugins.txt > ~/.config/zsh/.zsh_plugins.zsh"

RUN nvim --headless "+Lazy! sync" +qa

RUN nvim --headless "+Lazy! check" +qa

RUN nvim --headless -c "lua require('nvim-treesitter').install({'lua','cpp','vim','vimdoc','rust','go','java','nix','gitcommit','gitignore','json','yaml','bash','regex','markdown','markdown_inline','svelte','typescript','javascript','html','css','scss','vue'}):wait(300000)" -c "qa"

RUN curl -fsSL -o /tmp/tree-sitter.gz \
      "https://github.com/tree-sitter/tree-sitter/releases/download/v0.26.3/tree-sitter-linux-x64.gz" \
    && echo "4f65c8d9ba32a3e37198302569b3306f037f12d8313e3f28cdf1b80c9f2b3a3a  /tmp/tree-sitter.gz" | sha256sum -c - \
    && gunzip /tmp/tree-sitter.gz \
    && chmod +x /tmp/tree-sitter \
    && sudo mv /tmp/tree-sitter /usr/local/bin/tree-sitter

WORKDIR /home/ubuntu/work

