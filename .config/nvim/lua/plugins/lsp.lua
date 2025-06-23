return {
    {
        "williamboman/mason.nvim",
        opts = {
            ui = {
                width = 0.8,
                height = 0.8,
                border = require("utils.win.decorations").default_border,
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
            log_level = vim.log.levels.INFO,
            max_concurrent_installers = 4,
        },
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        opts = {
            ensure_installed = {
                "lua_ls",
                "jdtls",
                "bashls",
                "gopls",
                "rust_analyzer",
                "markdown_oxide",
                "taplo",
                "yamlls",
                "html",
                "jsonls",
                "ts_ls",
                "vuels",
                "terraformls",
                "tflint",
                "eslint",
            },
            automatic_installation = true,
        },
    },
    {
        {
            "folke/lazydev.nvim",
            ft = "lua",
            opts = {
                library = {
                    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                },
            },
        },
        {
            "hrsh7th/nvim-cmp",
            enabled = false,
            opts = function(_, opts)
                opts.sources = opts.sources or {}
                table.insert(opts.sources, {
                    name = "lazydev",
                    group_index = 0,
                })
            end,
        },
    },
    {
        "neovim/nvim-lspconfig",
        enabled = false,
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "SmiteshP/nvim-navbuddy",
            "SmiteshP/nvim-navic",
            "MunifTanjim/nui.nvim",
            opts = { lsp = { auto_attach = true } },
        },
        config = function()
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
                    border = require("utils.win.decorations").default_border,
                    source = true,
                    header = "",
                    prefix = "",
                },
            })

            local helpers = require("utils.win.decorations")
            local float_config = {
                border = helpers.default_border,
                highlight = {
                    Normal = "Normal",
                    FloatBorder = "FloatBorder",
                    Pmenu = "Pmenu",
                    SignatureHelp = "Normal",
                    SignatureHelpBorder = "FloatBorder",
                    PmenuSel = "PmenuSel",
                },
                syntax_highlighting = true,
            }

            -- Create a user command
            local lspinfo = require("utils.lsp.lspinfo")
            vim.api.nvim_create_user_command("LspInfoFloat", lspinfo.create_float, {})

            -- Configure LSP hover
            vim.lsp.handlers["textDocument/hover"] =
                vim.lsp.with(vim.lsp.handlers.hover, float_config)

            -- Configure LSP signature help
            vim.lsp.handlers["textDocument/signatureHelp"] =
                vim.lsp.with(vim.lsp.handlers.signature_help, { float_config })

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("reaper-lsp-attach", { clear = true }),
                callback = function(event)
                    local keymap = function(keys, func, desc)
                        vim.keymap.set(
                            "n",
                            keys,
                            func,
                            { buffer = event.buf, desc = "LSP: " .. desc }
                        )
                    end

                    keymap(
                        "gd",
                        require("telescope.builtin").lsp_definitions,
                        "[g]oto [d]efinition"
                    )
                    keymap("gD", vim.lsp.buf.declaration, "[g]oto [D]eclaration")
                    keymap("K", vim.lsp.buf.hover, "Hover Documentation")
                    keymap(
                        "gI",
                        require("telescope.builtin").lsp_implementations,
                        "[g]oto [I]mplementation"
                    )
                    keymap("gr", require("telescope.builtin").lsp_references, "[g]oto [r]eference")
                    keymap(
                        "<leader>D",
                        require("telescope.builtin").lsp_type_definitions,
                        "Type [D]efinition"
                    )
                    keymap("gl", vim.diagnostic.open_float, "Open Diagnostic")
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
                    keymap("<leader>li", "<cmd>LspInfoFloat<cr>", "[l]sp [i]nfo")
                    keymap("<leader>ca", vim.lsp.buf.code_action, "[c]ode [a]ctions")
                    keymap("<leader>rn", vim.lsp.buf.rename, "[r]e[n]ame")
                    keymap("<leader>ls", vim.lsp.buf.signature_help, "Signature Help")
                    keymap("<leader>lq", vim.diagnostic.setloclist, "Diagnostic Local List")

                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client.server_capabilities.documentHighlightProvider then
                        local highlight_augroup =
                            vim.api.nvim_create_augroup("reaper-lsp-highlight", { clear = false })
                        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })

                        vim.api.nvim_create_autocmd("LspDetach", {
                            group = vim.api.nvim_create_augroup(
                                "reaper-lsp-detach",
                                { clear = true }
                            ),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds({
                                    group = "reaper-lsp-highlight",
                                    buffer = event2.buf,
                                })
                            end,
                        })
                    end
                    -- The following autocommand is used to enable inlay hints in your
                    -- code, if the language server you are using supports them. This may
                    -- be unwanted, since they displace some of your code.
                    if
                        client
                        and client.server_capabilities.inlayHintProvider
                        and vim.lsp.inlay_hint
                    then
                        keymap(
                            "<leader>th",
                            function()
                                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
                            end,
                            "[T]oggle Inlay [H]ints"
                        )
                    end
                end,
            })
            require("lspconfig.ui.windows").default_options.border =
                require("utils.win.decorations").default_border

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend(
                "force",
                capabilities,
                require("cmp_nvim_lsp").default_capabilities()
            )

            local lspconfig = require("lspconfig")

            -- clang
            lspconfig.clangd.setup({
                keys = {
                    {
                        "<leader>ch",
                        "<cmd>ClangdSwitchSourceHeader<cr>",
                        desc = "Switch Source/Header (C/C++)",
                    },
                },
                root_dir = function(fname)
                    return require("lspconfig.util").root_pattern(
                        "Makefile",
                        "configure.ac",
                        "configure.in",
                        "config.h.in",
                        "meson.build",
                        "meson_options.txt",
                        "build.ninja"
                    )(fname) or require("lspconfig.util").root_pattern(
                        "compile_commands.json",
                        "compile_flags.txt"
                    )(fname) or require("lspconfig.util").find_git_ancestor(
                        fname
                    )
                end,
                capabilities = {
                    offsetEncoding = { "utf-16" },
                },
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--header-insertion=iwyu",
                    "--completion-style=detailed",
                    "--function-arg-placeholders",
                    "--fallback-style=llvm",
                },
                init_options = {
                    usePlaceholders = true,
                    completeUnimported = true,
                    clangdFileStatus = true,
                },
            })

            -- gopls
            for _, v in pairs(capabilities) do
                if type(v) == "table" and v.workspace then
                    v.workspace.didChangeWatchedFiles = {
                        dynamicRegistration = false,
                        relativePatternSupport = false,
                    }
                end
            end

            local gopls_settings = {
                gopls = {
                    experimentalPostfixCompletions = true,
                    semanticTokens = true,
                    analyses = {
                        unusedparams = true,
                        shadow = true,
                    },
                    staticcheck = true,
                    gofumpt = true,
                },
            }

            local gopls_init_options = {
                usePlaceholders = true,
                completeUnimported = true,
            }

            -- Check if BAZEL_WORKSPACE is set
            if vim.fn.environ()["BAZEL_WORKSPACE"] then
                -- Bazel-specific settings
                gopls_settings.gopls.buildFlags = { "-tags=bazel" }
                gopls_settings.gopls.env = {
                    -- GOPACKAGESDRIVER = vim.fn.expand("~/go/bin/gopackagesdriver.sh"),
                    BAZEL_WORKSPACE = vim.fn.getcwd(),
                }
            end

            lspconfig.gopls.setup({
                cmd = { "gopls", "-remote=auto", "-debug=localhost:6060", "-rpc.trace" },
                debounce_text_changes = 500,
                filetypes = { "go", "gomod", "gowork", "gotmpl" },
                settings = gopls_settings,
                init_options = gopls_init_options,
            })

            -- lspconfig.gopls.setup({
            --   capabilities = capabilities,
            --   -- cmd = { "gopls", "-remote=auto" },
            --   debounce_text_changes = 1000,
            --   filetypes = {
            --     "go",
            --     "gomod",
            --     "gowork",
            --     "gotmpl",
            --   },
            --   single_file_support = true,
            --   settings = {
            --     gopls = {
            --       analyses = {
            --         unusedparams = true,
            --       },
            --       staticcheck = true,
            --       gofumpt = true,
            --     },
            --   },
            -- })

            -- tsserver
            lspconfig.ts_ls.setup({
                capabilities = capabilities,
            })

            -- bashls
            lspconfig.bashls.setup({
                capabilities = capabilities,
                filetypes = {
                    "zsh",
                    "sh",
                    "zshrc",
                },
            })

            -- jsonls
            lspconfig.jsonls.setup({
                capabilities = capabilities,
            })

            -- eslint
            lspconfig.eslint.setup({
                capabilities = capabilities,
            })

            lspconfig.markdown_oxide.setup({
                capabilities = capabilities,
            })

            -- lua_ls
            lspconfig.lua_ls.setup({
                capabilities = capabilities,
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = "Replace",
                        },
                        workspace = {
                            checkThirdParty = false,
                        },
                    },
                },
            })
        end,
    },
}
