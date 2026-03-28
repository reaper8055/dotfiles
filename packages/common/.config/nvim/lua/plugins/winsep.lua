return {
    "nvim-zh/colorful-winsep.nvim",
    config = function() require("colorful-winsep").setup() end,
    border = "bold",
    event = {
        "winNew",
    },
}
