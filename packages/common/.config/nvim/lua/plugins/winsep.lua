return {
    "nvim-zh/colorful-winsep.nvim",
    enabled = true,
    opts = {
        -- Follow the colorscheme instead of the plugin's hardcoded purple.
        highlight = function() vim.api.nvim_set_hl(0, "ColorfulWinSep", { link = "Title" }) end,
    },
    event = {
        "WinLeave",
    },
}
