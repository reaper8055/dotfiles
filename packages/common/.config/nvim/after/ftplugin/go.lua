vim.g.go_def_mapping_enabled = 0
vim.opt_local.formatoptions:append("cqrn1")

local group_name = "GoAutoCmds"
local go_group = vim.api.nvim_create_augroup(group_name, { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.go",
    group = go_group, -- Assign the group
    callback = function()
        -- 2. Capture the client variable
        local client = vim.lsp.get_clients({ bufnr = 0 })[1]

        -- Check if LSP is attached
        if client == nil then return end

        -- 3. Pass the client's offset encoding to make_range_params
        -- (0 is the window id, defaulting to current)
        local params = vim.lsp.util.make_range_params(0, client.offset_encoding)

        params.context = { only = { "source.organizeImports" } }

        -- Organize imports
        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)

        for cid, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
                if r.edit then
                    local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                    vim.lsp.util.apply_workspace_edit(r.edit, enc)
                end
            end
        end

        -- No formatting here. conform.nvim's format_on_save already covers go
        -- via lsp_fallback -> gopls (which has gofumpt enabled). Calling
        -- vim.lsp.buf.format here too meant every :w formatted the buffer twice.
    end,
})

-- Treesitter folds. Highlighting and 'indentexpr' are already applied to every
-- buffer by the global FileType autocmd in lua/plugins/treesitter.lua, so this
-- only adds what that does not cover.
--
-- This runs in an ftplugin, which Neovim sources per go buffer, so the settings
-- apply directly -- wrapping them in a FileType autocmd here was both redundant
-- and wrong ('pattern' matches the filetype name "go", never the glob "*.go").
vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- Without this, 'foldlevel' defaults to 0 and every go file opens fully folded.
vim.opt_local.foldlevel = 99
