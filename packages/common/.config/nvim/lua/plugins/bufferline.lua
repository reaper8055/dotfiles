return {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("bufferline").setup({
            options = {
                numbers = "none", -- | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
                -- Was "Bdelete! %d", which needs vim-bbye/bufdelete.nvim -- neither
                -- is installed, so the close button silently errored. snacks.nvim
                -- is already loaded and its bufdelete preserves the window layout
                -- the way plain :bdelete does not.
                close_command = function(n) Snacks.bufdelete(n) end,
                right_mouse_command = function(n) Snacks.bufdelete(n) end,
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
