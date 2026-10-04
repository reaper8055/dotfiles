return {
    "nvim-mini/mini.pairs",
    version = "*",
    event = "InsertEnter",
    opts = {},
    config = function(_, opts)
        require("mini.pairs").setup(opts)

        -- mini.pairs maps globally; suppress it in prompt-style buffers the way
        -- nvim-autopairs' `disable_filetype` used to.
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("reaper-minipairs-disable", { clear = true }),
            pattern = { "TelescopePrompt", "spectre_panel", "snacks_input" },
            callback = function(event) vim.b[event.buf].minipairs_disable = true end,
        })
    end,
}
