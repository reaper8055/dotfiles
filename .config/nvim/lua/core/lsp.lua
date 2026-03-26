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
    print(internal_config)

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
                if type == "file" and name:match("%.lua$") then
                    --- @type lsp.ServerName
                    local server_name = name:gsub("%.lua$", "")
                    servers[server_name] = true
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
local win_decorations = require("utils.win.decorations")
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
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
        focusable = true,
        style = "minimal",
        border = win_decorations.default_border,
        -- border = "bold",
        source = true,
        header = "",
        prefix = "",
    },
})

-- Create user commands
local lspinfo = require("utils.lsp.lspinfo")
vim.api.nvim_create_user_command("LspInfoFloat", lspinfo.create_float, {})

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
                    border = win_decorations.default_border,
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
            "<leader>ws",
            require("telescope.builtin").lsp_dynamic_workspace_symbols,
            "[W]orkspace [S]ymbols"
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
                    border = require("utils.win.decorations").default_border,
                    focusable = false,
                })
            end,
            "Signature Help"
        )
        keymap("<leader>li", "<cmd>LspInfoFloat<cr>", "[l]sp [i]nfo")

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
            local highlight_augroup =
                vim.api.nvim_create_augroup("reaper-lsp-highlight", { clear = false })

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

            vim.api.nvim_create_autocmd("LspDetach", {
                group = vim.api.nvim_create_augroup("reaper-lsp-detach", { clear = true }),
                callback = function(event2)
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds({
                        group = "reaper-lsp-highlight",
                        buffer = event2.buf,
                    })
                end,
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
