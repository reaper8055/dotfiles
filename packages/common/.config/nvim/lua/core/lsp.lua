--- @alias lsp.ServerName string
--- @return lsp.ServerName[] # A flat list of server names to be enabled
local function get_available_lsps()
    --- @type string|nil
    local overlay_env = os.getenv("NVIM_OVERLAY")

    --- @type string
    local custom_path = overlay_env and vim.fn.expand(overlay_env) or vim.fn.expand("~/nvim-custom")

    --- @type table<lsp.ServerName, boolean>
    local servers = {}

    -- 2. Define standard locations to scan
    -- Using stdpath("config") ensures we find the base lua/lsp-servers directory
    --- @type string
    local internal_config = vim.fn.stdpath("config") .. "/lsp"

    --- @type string[]
    local paths_to_scan = { internal_config }

    -- 3. Defensive Check for Custom Path
    -- fs_stat returns a table with file info or nil
    local stat = vim.uv.fs_stat(custom_path)
    if stat and stat.type == "directory" then
        table.insert(paths_to_scan, custom_path .. "/lua/lsp-servers")

        -- Prepend to RTP so 'require' works for these files if needed
        -- Defensive: Check if it's already there to maintain idempotency
        --- @type string[]
        local rtp = vim.opt.rtp:get()
        if not vim.tbl_contains(rtp, custom_path) then vim.opt.rtp:prepend(custom_path) end
    end

    -- 4. Optimized Discovery (Avoids full RTP scan)
    for _, path in ipairs(paths_to_scan) do
        --- @type uv.uv_fs_t|nil
        local handle = vim.uv.fs_scandir(path)
        if handle then
            while true do
                local name, type = vim.uv.fs_scandir_next(handle)
                if not name then break end
                -- fs_scandir reports "link" for symlinks, and stow-managed
                -- configs are all symlinks. Checking `type == "file"` here
                -- silently skips every server. fs_stat follows the link.
                if name:match("%.lua$") then
                    --- @type uv.fs_stat.result|nil
                    local entry_stat = vim.uv.fs_stat(path .. "/" .. name)
                    if entry_stat and entry_stat.type == "file" then
                        --- @type lsp.ServerName
                        local server_name = name:gsub("%.lua$", "")
                        servers[server_name] = true
                    end
                end
            end
        end
    end

    return vim.tbl_keys(servers)
end

-- 5. Execution with Error Boundary
local lsps = get_available_lsps()

if #lsps > 0 then
    -- pcall is used here like a 'recover' block in Go
    local ok, err = pcall(vim.lsp.enable, lsps)
    if not ok then
        vim.notify(
            string.format("LSP Overlay Error: %s", tostring(err)),
            vim.log.levels.ERROR,
            { title = "LSP Loader" }
        )
    end
end

-- Diagnostic configuration
vim.diagnostic.config({
    virtual_text = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.INFO] = " ",
        },
    },
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
        focusable = true,
        style = "minimal",
        source = true,
        header = "",
        prefix = "",
    },
})

-- :LspInfo is our own float; `:checkhealth vim.lsp` has the full dump.
vim.api.nvim_create_user_command("LspInfo", function() require("utils.lsp.info").open() end, { desc = "LSP info" })
vim.api.nvim_create_user_command(
    "LspRestart",
    function(opts) vim.cmd("lsp restart " .. opts.args) end,
    { nargs = "*", desc = "Restart LSP clients (all attached, or the named ones)" }
)

-- Created once, at module scope. `clear = false` so that per-buffer autocmds
-- registered into it on LspAttach survive; they are cleared per buffer instead.
local highlight_augroup = vim.api.nvim_create_augroup("reaper-lsp-highlight", { clear = false })

-- Registered ONCE, not per attach. Previously this lived inside the LspAttach
-- callback and created its augroup with `clear = true`, so every new attach
-- wiped the handler belonging to every previously attached buffer.
vim.api.nvim_create_autocmd("LspDetach", {
    group = vim.api.nvim_create_augroup("reaper-lsp-detach", { clear = true }),
    callback = function(event)
        vim.lsp.buf.clear_references()
        vim.api.nvim_clear_autocmds({ group = highlight_augroup, buffer = event.buf })
    end,
})

-- LspAttach autocommand with complete keymap configuration
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("reaper-lsp-attach", { clear = true }),
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        local bufnr = event.buf

        local keymap = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
        end

        -- Navigation keymaps
        keymap("gd", require("telescope.builtin").lsp_definitions, "[g]oto [d]efinition")
        keymap("gD", vim.lsp.buf.declaration, "[g]oto [D]eclaration")
        keymap(
            "K",
            function()
                vim.lsp.buf.hover({
                    max_width = math.floor(vim.o.columns * 0.7),
                    max_height = math.floor(vim.o.lines * 0.3),
                })
            end,
            "Hover Documentation"
        )
        keymap("gI", require("telescope.builtin").lsp_implementations, "[g]oto [I]mplementation")
        keymap("gr", require("telescope.builtin").lsp_references, "[g]oto [r]eference")
        keymap("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

        -- Diagnostic keymaps
        keymap("gl", vim.diagnostic.open_float, "Open Diagnostic")
        keymap("<leader>lq", vim.diagnostic.setloclist, "Diagnostic Local List")

        -- Symbol navigation
        keymap(
            "<leader>ds",
            require("telescope.builtin").lsp_document_symbols,
            "[D]ocument [S]ymbols"
        )
        keymap(
            "<leader>sS",
            require("telescope.builtin").lsp_dynamic_workspace_symbols,
            "[S]earch Workspace [S]ymbols"
        )

        -- LSP actions
        keymap("<leader>ca", vim.lsp.buf.code_action, "[c]ode [a]ctions")
        keymap("<leader>rn", vim.lsp.buf.rename, "[r]e[n]ame")
        keymap(
            "<leader>ls",
            function()
                vim.lsp.buf.signature_help({
                    max_width = math.floor(vim.o.columns * 0.7),
                    max_height = math.floor(vim.o.lines * 0.3),
                    focusable = false,
                })
            end,
            "Signature Help"
        )
        keymap("<leader>li", "<cmd>LspInfo<cr>", "[l]sp [i]nfo")

        -- Language-specific keymaps
        if client and client.name == "clangd" then
            keymap(
                "<leader>ch",
                "<cmd>ClangdSwitchSourceHeader<cr>",
                "Switch Source/Header (C/C++)"
            )
        end

        -- Document highlighting setup
        if client and client.server_capabilities.documentHighlightProvider then
            -- clear existing autocmds for this specific buffer to avoid duplicates
            vim.api.nvim_clear_autocmds({ group = highlight_augroup, buffer = bufnr })

            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = bufnr,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                buffer = bufnr,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
            })
        end

        -- Inlay hints toggle
        if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            keymap(
                "<leader>th",
                function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
                "[T]oggle Inlay [H]ints"
            )
        end
    end,
})
