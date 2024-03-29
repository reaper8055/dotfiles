return {
  "olimorris/onedarkpro.nvim",
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
}
