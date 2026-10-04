return {
    "nvim-lualine/lualine.nvim",
    enabled = true,
    dependencies = {
        {
            "nvim-tree/nvim-web-devicons",
            opt = true,
        },
    },
    config = function()
        require("lualine").setup({
            options = {
                icons_enabled = true,
                globalstatus = true,
                -- theme = vim.g.colors_name,
                disabled_filetypes = {},
                always_divide_middle = true,
                -- lualine's own defaults. The previous value of 20 rebuilt the
                -- statusline 50 times a second; tabline/winbar are empty here
                -- anyway (bufferline owns the tabline).
                refresh = {
                    statusline = 1000,
                    tabline = 1000,
                    winbar = 1000,
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
