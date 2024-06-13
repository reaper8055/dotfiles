return {
  "nvim-treesitter/nvim-treesitter",
  build = function()
    local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
    ts_update()
  end,
  dependencies = {
    "nvim-treesitter/nvim-treesitter-refactor",
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  event = "bufWinEnter",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "rust",
        "go",
        "nix",
        "gitcommit",
        "gitignore",
        "json",
        "yaml",
        "bash",
        "regex",
        "markdown",
        "markdown_inline",
        -- web development
        "svelte",
        "typescript",
        "javascript",
        "html",
        "css",
        "scss",
        "vue",
      },
      sync_install = false,
      auto_install = true,
      ignore_install = { "" },
      autopairs = {
        enable = true,
      },
      highlight = {
        enable = true,
        disable = { "" },
        additional_vim_regex_highlighting = true,
      },
      indent = {
        enable = true,
        disable = { "yaml" },
      },
      refactor = {
        highlight_current_scope = { enable = false },
        highlight_definitions = {
          enable = true,
          -- Set to false if you have an `updatetime` of ~100.
          clear_on_cursor_move = true,
        },
      },
      smart_rename = {
        enable = true,
        -- Assign keymaps to false to disable them, e.g. `smart_rename = false`.
        keymaps = {
          smart_rename = "grr",
        },
      },
      rainbow = {
        enable = true,
        -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
        extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
        max_file_lines = nil, -- Do not enable for files with more than n lines, int
        -- colors = {}, -- table of hex strings
        -- termcolors = {} -- table of colour name strings
      },
    })
  end,
}
