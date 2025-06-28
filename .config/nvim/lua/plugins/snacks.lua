return {
    "folke/snacks.nvim",
    enabled = true,
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        styles = {
            input = {
                border = require("utils.win.decorations").default_border,
                width = 40,
                relative = "cursor",
            },
            win = {
                border = require("utils.win.decorations").default_border,
            },
            notification = {
                border = require("utils.win.decorations").default_border,
            },
        },
        bigfile = { enabled = true },
        dashboard = {
            enabled = true,
            preset = {
                -- Use telescope as the picker instead of snacks picker
                pick = function(cmd, opts)
                    opts = opts or {}
                    local telescope = require("telescope.builtin")

                    -- Map snacks picker commands to telescope commands
                    local telescope_commands = {
                        files = "find_files",
                        oldfiles = "oldfiles",
                        live_grep = "live_grep",
                        grep = "live_grep",
                        buffers = "buffers",
                        git_files = "git_files",
                        help_tags = "help_tags",
                        commands = "commands",
                        keymaps = "keymaps",
                    }

                    local telescope_cmd = telescope_commands[cmd] or cmd

                    if telescope[telescope_cmd] then
                        telescope[telescope_cmd](opts)
                    else
                        vim.notify(
                            "Unknown telescope command: " .. telescope_cmd,
                            vim.log.levels.WARN
                        )
                    end
                end,
            },
        },
        explorer = { enabled = true },
        indent = { enabled = false },
        input = { enabled = true },
        picker = { enabled = false },
        notifier = { enabled = false },
        quickfile = { enabled = true },
        scope = { enabled = false },
        scroll = { enabled = false },
        statuscolumn = { enabled = false },
        words = { enabled = true },
    },
}
