return {
    "hrsh7th/nvim-cmp",
    enabled = false,
    lazy = false,
    event = "InsertEnter",
    dependencies = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "hrsh7th/cmp-omni",
        "saadparwaiz1/cmp_luasnip",
        {
            "L3MON4D3/LuaSnip",
            version = "v2.*",
            build = "make install_jsregexp",
        },
        "neovim/nvim-lspconfig",
        "rafamadriz/friendly-snippets",
        "onsails/lspkind.nvim",
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local luasnip_vscode = require("luasnip.loaders.from_vscode")
        local lspkind = require("lspkind")

        luasnip.config.set_config({
            history = true,
            updateevents = "TextChanged,TextChangedI",
            enable_autosnippets = true,
            store_selection_keys = "<Tab>",
        })

        local helpers = require("utils.win.decorations")
        cmp.setup({
            snippet = {
                expand = function(args) luasnip.lsp_expand(args.body) end,
            },
            window = {
                completion = {
                    border = helpers.default_border,
                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
                },
                documentation = {
                    border = helpers.default_border,
                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
                },
            },

            completion = { completeopt = "menu,menuone,noinsert" },
            mapping = cmp.mapping.preset.insert({
                ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
                ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
                ["<C-x><C-o>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
                ["<C-e>"] = cmp.mapping({
                    i = cmp.mapping.abort(),
                    c = cmp.mapping.close(),
                }),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
            }),
            formatting = {
                format = lspkind.cmp_format({
                    mode = "text_symbol",
                    maxwidth = {
                        menu = function() return math.floor(0.45 * vim.o.columns) end,
                        abbr = function() return math.floor(0.45 * vim.o.columns) end,
                    },
                    ellipsis_char = "...",
                    show_labelDetails = true,
                    before = function(entry, vim_item)
                        -- ...
                        return vim_item
                    end,
                }),
            },
            sources = cmp.config.sources({
                {
                    name = "lazydev",
                    group_index = 0,
                },
                { name = "nvim_lsp_signature_help" },
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "buffer" },
                { name = "path" },
            }),
            confirm_opts = {
                behavior = cmp.ConfirmBehavior.Replace,
                select = false,
            },
        })
        -- Create a custom mapping for cmdline mode
        local cmdline_mappings = cmp.mapping.preset.cmdline()

        -- Override the <CR> behavior to select without executing
        cmdline_mappings["<CR>"] = cmp.mapping({
            i = function(fallback)
                if cmp.visible() then
                    cmp.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert })
                else
                    fallback()
                end
            end,
            s = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert }),
            c = function(fallback)
                if cmp.visible() then
                    cmp.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert })
                else
                    fallback()
                end
            end,
        })

        -- `/` and `?` cmdline setup
        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = "buffer" },
            },
            completion = {
                completeopt = "menu,menuone",
            },
        })

        -- `:` cmdline setup
        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = "path" },
            }, {
                { name = "cmdline" },
            }),
            matching = { disallow_symbol_nonprefix_matching = false },
            completion = {
                completeopt = "menu,menuone",
            },
        })

        luasnip_vscode.lazy_load()
    end,
}
