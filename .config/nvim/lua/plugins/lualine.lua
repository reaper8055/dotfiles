return {
    "nvim-lualine/lualine.nvim",
    enabled = true,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        opt = true,
    },
    config = function()
        -- Get Kanagawa colors
        local colors = require("kanagawa.colors").setup()
        local theme = colors.theme

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
                            left = "",
                            right = "",
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
                            right = "",
                        },
                    },
                },
                lualine_c = {
                    {
                        "diagnostics",
                        sections = { "error", "warn", "info", "hint" },
                        symbols = { error = " ", warn = " ", info = " ", hint = " " },
                        colored = true,
                        color = {
                            bg = theme.ui.bg,
                        },
                        separator = {
                            left = "",
                            right = "",
                        },
                        source = { "nvim" },
                    },
                },
                lualine_x = {
                    {
                        "diff",
                        colored = true,
                        symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
                        color = {
                            bg = theme.ui.bg,
                            fg = theme.ui.fg,
                        },
                        cond = function() return vim.fn.winwidth(0) > 80 end,
                        separator = {
                            right = "",
                            left = "",
                        },
                    },
                },
                lualine_y = {
                    {
                        "filetype",
                        separator = {
                            right = "",
                            left = "",
                        },
                    },
                    {
                        "encoding",
                        color = {
                            bg = theme.ui.bg,
                        },
                        separator = {
                            right = "",
                            left = "",
                        },
                    },
                },
                lualine_z = {
                    {
                        "searchcount",
                        fmt = function(str) return str:gsub("%[", ""):gsub("%]", "") end,
                        maxcount = 99999,
                        color = {
                            bg = colors.palette.autumnYellow,
                        },
                        padding = 1,
                        separator = {
                            right = "",
                            left = "",
                        },
                    },
                    {
                        "location",
                        icon = {
                            " ",
                            align = "right",
                        },
                        padding = 1,
                        separator = {
                            right = "",
                            left = "",
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
            winbar = {},
            inactive_winbar = {},
            extensions = {},
        })
    end,
}
