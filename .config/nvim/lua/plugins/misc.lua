return {
  { "nvim-lua/popup.nvim" },
  { "nvim-lua/plenary.nvim" },
  { "nvim-tree/nvim-web-devicons" },

  -- lspkind
  { "onsails/lspkind.nvim" },

  -- vim-tmux-navigator
  { "christoomey/vim-tmux-navigator" },

  -- vim-fugitive
  { "tpope/vim-fugitive" },

  -- vim-test
  { "vim-test/vim-test" },

  -- kitty.conf syntax highlighting
  { "fladson/vim-kitty" },

  -- dressing
  {
    "stevearc/dressing.nvim",
    opts = {},
  },

  -- vim-go
  {
    "fatih/vim-go",
    enabled = false,
  },

  -- colorschemes
  {
    "rebelot/kanagawa.nvim",
    {
      "rose-pine/neovim",
      name = "rose-pine",
    },
    {
      "catppuccin/nvim",
      name = "catppuccin",
    },
  },
}
