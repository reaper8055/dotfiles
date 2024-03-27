return {
  "olimorris/onedarkpro.nvim",
  priority = 1000,
  config = function()
    vim.cmd("colorscheme onedark")
    vim.cmd([[highlight CursorColumn guibg=#2D313B]])
    vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#282C34", fg = "#ABB2BF" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#282C34" })
    vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "#282C34" })
    vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "#282C34" })
  end,
}
