return {
  "rebelot/kanagawa.nvim",
  enabled = true,
  priority = 2000,
  config = function()
    -- Default options:
    require("kanagawa").setup({
      compile = false, -- enable compiling the colorscheme
      undercurl = true, -- enable undercurls
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = false, -- do not set background color
      dimInactive = false, -- dim inactive window `:h hl-NormalNC`
      terminalColors = true, -- define vim.g.terminal_color_{0,17}
      colors = { -- add/modify theme and palette colors
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
      theme = "wave", -- Load "wave" theme when 'background' option is not set
      background = { -- map the value of 'background' option to a theme
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

    local function set_diagnostic_colors()
      local colors = {
        ok = "#a8d4b0",
        hint = "#a8c5e0",
        info = "#b4befe",
        warn = "#e0c49c",
        error = "#e0a8a8",
      }

      for _, type in ipairs({ "Ok", "Hint", "Info", "Warn", "Error" }) do
        local color = colors[type:lower()]
        vim.api.nvim_set_hl(0, "Diagnostic" .. type, { fg = color })
        vim.api.nvim_set_hl(0, "DiagnosticSign" .. type, { fg = color })
        vim.api.nvim_set_hl(0, "DiagnosticFloating" .. type, { fg = color })
        vim.api.nvim_set_hl(0, "DiagnosticVirtualText" .. type, { fg = color })
        vim.api.nvim_set_hl(0, "DiagnosticUnderline" .. type, { undercurl = true, sp = color })
      end

      vim.api.nvim_set_hl(0, "DiagnosticDeprecated", { strikethrough = true, fg = colors.warn })
      vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", { fg = colors.hint, italic = true })
    end

    -- Run immediately
    set_diagnostic_colors()

    -- Run on colorscheme change
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_diagnostic_colors,
    })
  end,
}
