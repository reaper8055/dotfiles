return {
    "mason-org/mason.nvim",
    opts = {
        ui = {
            width = 0.8,
            height = 0.8,
            border = require("utils.win.decorations").default_border,
            backdrop = 100,
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗",
            },
        },
        log_level = vim.log.levels.INFO,
        max_concurrent_installers = 4,
    },
}
