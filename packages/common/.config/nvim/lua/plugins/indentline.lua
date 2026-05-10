return {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
        require("ibl").setup({
            indent = {
                char = "┃",
                tab_char = "┃",
                -- char = "┃",
                smart_indent_cap = true,
            },
            scope = {
                injected_languages = false,
                show_start = false,
                show_end = false,
                include = {
                    node_type = {
                        ["*"] = { "*" },
                    },
                },
            },
        })
    end,
}
