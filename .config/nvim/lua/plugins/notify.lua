return {
    "echasnovski/mini.notify",
    version = "*",
    config = function()
        -- Function to get 12-hour format time with AM/PM
        local function get_time_12hr()
            return os.date("%I:%M %p") -- e.g., "11:30 AM"
        end

        -- Icons for different log levels
        local icons = {
            INFO = " ",
            WARN = " ",
            ERROR = " ",
            DEBUG = " ",
            TRACE = " ",
        }

        -- Custom format function
        local function custom_format(notification)
            local icon = icons[notification.level] or "󰋼 "
            local time = get_time_12hr()
            local title = notification.title and notification.title .. ": " or ""

            -- Format: [11:30 AM]  Warning: Your message here
            return string.format("[%s]: %s %s%s", time, icon, title, notification.msg)
        end

        local helpers = require("utils.win.decorations")
        require("mini.notify").setup({
            content = {
                format = custom_format,
            },
            window = {
                config = function()
                    -- Get editor dimensions
                    local columns = vim.o.columns
                    local lines = vim.o.lines

                    return {
                        anchor = "SE",
                        border = helpers.default_border,
                        col = columns - 1,
                        row = lines - 2,
                        relative = "editor",
                        style = "minimal",
                    }
                end,
            },
            lsp_progress = {
                enable = false,
            },
        })

        -- Override vim.notify with mini.notify
        local notify = require("mini.notify").make_notify()
        vim.notify = notify
    end,
}
