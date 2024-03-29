return {
  "nvim-lualine/lualine.nvim",
  enabled = true,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    opt = true,
  },
  config = function()
    require("lualine").setup({
      options = {
        icons_enabled = true,
        -- theme = "onedark",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          "aerial",
          "NvimTree",
          "Outline",
        },
        always_divide_middle = true,
      },
      sections = {
        lualine_a = {
          {
            "branch",
            icons_enabled = true,
            icon = "",
            padding = 1,
          },
        },
        lualine_b = {
          {
            "mode",
            padding = 1,
          },
        },
        lualine_c = {},
        lualine_x = {
          {
            "diff",
            colored = false,
            symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
            cond = function() return vim.fn.winwidth(0) > 80 end,
            color = {
              bg = "#98C379",
              fg = "#282C34",
            },
          },
          "encoding",
        },
        lualine_y = {
          {
            "location",
            padding = 1,
          },
        },
        lualine_z = {},
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = {},
    })
  end,
}
