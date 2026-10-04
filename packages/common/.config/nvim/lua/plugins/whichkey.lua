return {
    "folke/which-key.nvim",
    opts = {
        delay = 100,
        preset = "classic",
        win = {
            title = false,
            border = require("utils.win.decorations").default_border,
        },
        icons = {
            mappings = false,
        },
    },
    keys = {
        {
            "<leader>?",
            function() require("which-key").show({ global = false }) end,
            desc = "Buffer Local Keymaps (which-key)",
        },
    },
}
