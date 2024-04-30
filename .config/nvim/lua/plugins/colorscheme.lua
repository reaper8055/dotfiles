return {
  {
    "olimorris/onedarkpro.nvim",
    enabled = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme onedark")
      -- vim.cmd("colorscheme kanagawa")

      local helpers = require("utils.helpers")
      local colors = helpers.get_hlg_colors()
      -- vim.api.nvim_set_hl(0, "LineNr", { fg = colors.fg, bg = colors.bg })
      -- vim.api.nvim_set_hl(0, "FoldColumn", { fg = colors.fg, bg = colors.bg })
      -- vim.api.nvim_set_hl(0, "SignColumn", { fg = colors.fg, bg = colors.bg })
      vim.api.nvim_set_hl(0, "CursorColumn", { bg = "#2D313B" })
      vim.api.nvim_set_hl(0, "FloatBorder", { bg = colors.bg, fg = colors.fg })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = colors.bg, fg = colors.fg })
      vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = colors.bg })
      vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = colors.bg })
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    enabled = true,
    priority = 2000,
    config = function()
      -- Default options:
      require("kanagawa").setup({
        compile = false,  -- enable compiling the colorscheme
        undercurl = true, -- enable undercurls
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = false,   -- do not set background color
        dimInactive = false,   -- dim inactive window `:h hl-NormalNC`
        terminalColors = true, -- define vim.g.terminal_color_{0,17}
        colors = {             -- add/modify theme and palette colors
          palette = {},
          theme = {
            wave = {},
            lotus = {},
            dragon = {},
            all = {
              ui = {
                bg_gutter = "none",
              },
            },
          },
        },
        theme = "wave",  -- Load "wave" theme when 'background' option is not set
        background = {   -- map the value of 'background' option to a theme
          dark = "wave", -- try "dragon" !
          light = "lotus",
        },
      })

      -- setup must be called before loading
      vim.cmd("colorscheme kanagawa")

      local helpers = require("utils.helpers")
      local colors = helpers.get_hlg_colors()

      vim.api.nvim_set_hl(0, "FloatBorder", { bg = colors.bg, fg = colors.fg })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = colors.bg, fg = colors.fg })
      vim.api.nvim_set_hl(0, "CursorLine", { bg = colors.bg })
      vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = colors.bg })
      vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = colors.bg })
    end,
  },
}
