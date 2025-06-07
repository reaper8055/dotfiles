return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = {
    "rebelot/kanagawa.nvim",
    "nvim-tree/nvim-web-devicons",
    "rebelot/kanagawa.nvim",
  },
  config = function()
    require("bufferline").setup({
      highlights = function()
        -- Get Kanagawa colors
        local colors = require("kanagawa.colors").setup()
        local palette = colors.palette

        return {
          tab_selected = {
            fg = palette.carpYellow,
          },
          tab_close = {
            fg = palette.carpYellow,
          },
          tab_separator_selected = {
            fg = palette.carpYellow,
          },
          buffer_selected = {
            fg = palette.carpYellow,
          },
          indicator_selected = {
            fg = palette.carpYellow,
          },
          close_button_selected = {
            fg = palette.carpYellow,
          },
          separator_selected = {
            fg = palette.carpYellow,
            bg = palette.carpYellow,
          },
        }
      end,
      options = {
        numbers = "none", -- | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
        close_command = "Bdelete! %d", -- can be a string | function, see "Mouse actions"
        right_mouse_command = "Bdelete! %d", -- can be a string | function, see "Mouse actions"
        left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
        middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"
        indicator = {
          style = "icon",
          icon = "▎",
        },
        offsets = {
          {
            filetype = "NvimTree",
            text = "󰙅 File Explorer",
            text_align = "left",
            separator = true,
          },
        },
        color_icons = true,
        buffer_close_icon = "",
        modified_icon = "●",
        close_icon = "",
        left_trunc_marker = " ",
        right_trunc_marker = " ",
        max_name_length = 30,
        max_prefix_length = 30, -- prefix used when a buffer is de-duplicated
        tab_size = 20,
        diagnostics = false,
        diagnostics_update_in_insert = false,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
        separator_style = "thin",
        enforce_regular_tabs = true,
        always_show_bufferline = true,
      },
    })
  end,
}
