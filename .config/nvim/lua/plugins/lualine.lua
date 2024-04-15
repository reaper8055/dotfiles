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
        -- theme = vim.g.colors_name,
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
            separator = {
              left = "",
              right = "",
            },
          },
        },
        lualine_b = {
          {
            "mode",
            icons_enabled = true,
            padding = 1,
            separator = {
              left = "",
              right = "",
            },
          },
        },
        lualine_c = {},
        lualine_x = {
          {
            "diff",
            colored = true,
            symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
            cond = function() return vim.fn.winwidth(0) > 80 end,
            separator = {
              right = "",
              left = "",
            },
          },
        },
        lualine_y = {
          {
            "encoding",
            separator = {
              right = "",
              left = "",
            },
          },
          "filetype",
        },
        lualine_z = {
          {
            "location",
            icon = {
              " ",
              align = "right",
            },
            padding = 0,
            separator = {
              right = "",
              left = "",
            },
          },
        },
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
