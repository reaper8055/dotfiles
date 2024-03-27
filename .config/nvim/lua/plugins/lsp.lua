return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
        log_level = vim.log.levels.INFO,
        max_concurrent_installers = 4,
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "bashls",
          "gopls",
          "lua_ls",
          "rust_analyzer",
          "zk",
          "taplo",
          "terraformls",
          "yamlls",
          "html",
          "jsonls",
          "tsserver",
          "vuels",
          "terraformls",
          "tflint",
          "eslint",
          "prettier",
        },
        automatic_installation = true,
      })
    end,
  },
  {
    "folke/neodev.nvim",
    config = function() require("neodev").setup({}) end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local signs = {
        { name = "DiagnosticSignError", text = " " },
        { name = "DiagnosticSignWarn", text = " " },
        { name = "DiagnosticSignHint", text = " " },
        { name = "DiagnosticSignInfo", text = " " },
      }

      for _, sign in ipairs(signs) do
        vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
      end

      vim.diagnostic.config({
        virtual_text = true,
        signs = {
          active = signs, -- show signs
        },
        update_in_insert = true,
        underline = true,
        severity_sort = true,
        float = {
          focusable = true,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
      })

      vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(vim.lsp.handlers.signature_help, {
          border = "rounded",
        })

      require("lspconfig.ui.windows").default_options.border = "rounded"

      local on_attach = function(client, bufnr)
        print("on_attach worked!!")
        local opts = { buffer = bufnr, noremap = true, silent = true }

        local keymap = vim.keymap.set
        keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
        keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
        keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
        keymap("n", "gI", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
        keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
        keymap("n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
        keymap("n", "<leader>lf", "<cmd>lua vim.lsp.buf.format{ async = true }<cr>", opts)
        keymap("n", "<leader>li", "<cmd>LspInfo<cr>", opts)
        keymap("n", "<leader>lI", "<cmd>LspInstallInfo<cr>", opts)
        keymap("n", "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
        keymap("n", "<leader>lj", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>", opts)
        keymap("n", "<leader>lk", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", opts)
        keymap("n", "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
        keymap("n", "<leader>ls", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
        keymap("n", "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)

        client.server_capabilities.document_formatting = true
      end

      local lspconfig = require("lspconfig")
      -- local util = require("lspconfig/util")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- gopls
      lspconfig.gopls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        cmd = { "gopls", "-remote=auto" },
        debounce_text_changes = 1000,
        filetypes = {
          "go",
          "gomod",
          "gowork",
          "gotmpl",
        },
        -- root_dir = util.root_pattern("go.work", "go.mod", ".git"),
        single_file_support = true,
        settings = {
          gopls = {
            gofumpt = true,
            completeUnimported = true,
            staticcheck = true,
            hoverKind = "FullDocumentation",
            linkTarget = "pkg.go.dev",
            usePlaceholders = true,
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })

      -- tsserver
      lspconfig.tsserver.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- bashls
      lspconfig.bashls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        filetypes = {
          "zsh",
          "sh",
        },
      })

      -- jsonls
      lspconfig.jsonls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- eslint
      lspconfig.eslint.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- lua_ls
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
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
