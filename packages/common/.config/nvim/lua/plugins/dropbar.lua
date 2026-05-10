return {
    "Bekaboo/dropbar.nvim",
    enabled = true,
    dependencies = {
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },
    },
    config = function()
        local dropbar = require("dropbar")
        local dropbar_api = require("dropbar.api")

        dropbar.setup({
            bar = {
                enable = function(buf, win, info)
                    buf = vim._resolve_bufnr(buf)

                    if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
                        return false
                    end

                    if vim.bo[buf].filetype == "NvimTree" then return false end

                    if
                        vim.fn.win_gettype(win) ~= ""
                        or vim.wo[win].winbar ~= ""
                        or vim.bo[buf].filetype == "help"
                    then
                        return false
                    end

                    local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
                    if stat and stat.size > 1024 * 1024 then return false end

                    return vim.bo[buf].buftype == "terminal"
                        or vim.bo[buf].filetype == "markdown"
                        or pcall(vim.treesitter.get_parser, buf)
                        or not vim.tbl_isempty(vim.lsp.get_clients({
                            bufnr = buf,
                            method = "textDocument/documentSymbol",
                        }))
                end,
            },
        })

        vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
        vim.keymap.set("n", "[;", dropbar_api.goto_context_start, {
            desc = "Go to start of current context",
        })
        vim.keymap.set("n", "];", dropbar_api.select_next_context, {
            desc = "Select next context",
        })
    end,
}
