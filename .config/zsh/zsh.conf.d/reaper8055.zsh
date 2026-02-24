#!/usr/bin/env zsh

# Add autoload function directory
fpath=("$XDG_CONFIG_HOME/zsh/functions" $fpath)

# Register autoload functions
autoload -Uz \
  set-copy-alias \
  gen-nix-shell \
  gen-envrc \
  nix-init \
  nix-upgrade \
  project-init \
  gogh

# Initialize clipboard alias based on platform/tool availability
set-copy-alias


