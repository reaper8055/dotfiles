return {
  "nvim-lualine/lualine.nvim",
  enabled = true,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    opt = true,
  },
  config = function()
    local helpers = require("utils.helpers")
    local colors = helpers.get_hlg_colors()

    require("lualine").setup({
      options = {
        icons_enabled = true,
        globalstatus = true,
        theme = vim.g.colors_name,
        disabled_filetypes = {},
        always_divide_middle = true,
        refresh = {
          statusline = 20,
          tabline = 20,
          winbar = 20,
        },
      },
      sections = {
        lualine_a = {
          {
            "branch",
            icons_enabled = true,
            icon = "",
            padding = 1,
            separator = {
              left = "  ",
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
        lualine_c = {
          {
            "diagnostics",
            colored = true,
            color = {
              bg = colors.bg,
            },
            separator = {
              left = "",
              right = "",
            },
            source = { "nvim" },
            sections = { "error" },
          },
          {
            "diagnostics",
            colored = true,
            color = {
              bg = colors.bg,
            },
            separator = {
              left = "",
              right = "",
            },
            source = { "nvim" },
            sections = { "warn" },
          },
        },
        lualine_x = {
          {
            "diff",
            colored = true,
            symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
            color = {
              bg = colors.bg,
            },
            cond = function() return vim.fn.winwidth(0) > 80 end,
            separator = {
              right = "",
              left = "",
            },
          },
        },
        lualine_y = {
          {
            "filetype",
            separator = {
              right = "",
              left = "",
            },
          },
          {
            "encoding",
            color = {
              bg = colors.bg,
            },
            separator = {
              right = "",
              left = "",
            },
          },
        },
        lualine_z = {
          {
            "location",
            icon = {
              " ",
              align = "right",
            },
            padding = 1,
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
