return {
    "rebelot/kanagawa.nvim",
    lazy = false,
    enabled = true,
    priority = 2000,
    config = function()
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
            overrides = function(colors)
                local theme = colors.theme
                local palette = colors.palette

                local diagnostic_colors = {
                    Ok = palette.waveAqua2,
                    Hint = palette.dragonBlue,
                    Info = palette.waveAqua1,
                    Warn = palette.carpYellow,
                    Error = palette.autumnRed,
                }

                local highlights = {
                    -- Float related highlights
                    FloatBorder = { bg = theme.ui.bg, fg = palette.fujiWhite },
                    NormalFloat = { bg = theme.ui.bg, fg = theme.ui.fg },
                    CursorLine = { bg = theme.ui.bg },
                    FloatTitle = { bg = theme.ui.bg, fg = palette.fujiWhite },
                    DressingInputText = { bg = theme.ui.bg },
                    DressingInputBorder = { bg = theme.ui.bg, fg = palette.fujiWhite },
                    TelescopeTitle = { fg = theme.ui.fg, bold = true },
                    TelescopeNormal = { bg = theme.ui.bg, fg = theme.ui.fg },
                    TelescopeBorder = { bg = theme.ui.bg, fg = theme.ui.fg },

                    -- Popup menu highlights
                    Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
                    PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
                    PmenuSbar = { bg = theme.ui.bg_m1 },
                    PmenuThumb = { bg = theme.ui.bg_p2 },

                    -- Indent-blankline highlight
                    LightGray = { fg = theme.ui.fg },
                }

                for type, color in pairs(diagnostic_colors) do
                    highlights["Diagnostic" .. type] = { fg = color }
                    highlights["DiagnosticSign" .. type] = { fg = color }
                    highlights["DiagnosticFloating" .. type] = { fg = color }
                    highlights["DiagnosticVirtualText" .. type] = { fg = color }
                    highlights["DiagnosticUnderline" .. type] = { undercurl = true, sp = color }
                end

                highlights.DiagnosticDeprecated = { strikethrough = true, fg = palette.fujiGray }
                highlights.DiagnosticUnnecessary = { fg = palette.fujiGray, italic = true }

                return highlights
            end,
        })

        -- setup must be called before loading
        vim.cmd("colorscheme kanagawa")
    end,
}
