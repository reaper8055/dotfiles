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
    # lua
    stylua
  ];
  shellHook = ''
    export GIT_CONFIG_NOSYSTEM=true
    export GIT_CONFIG_SYSTEM="$HOME/dotfiles/.config/github/github_config_global"
    export GIT_CONFIG_GLOBAL="$HOME/dotfiles/.config/github/github_config_global"
  '';
}
