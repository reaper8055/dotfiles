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
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "bashls",
          "shellcheck",
          "gopls",
          "rust_analyzer",
          "markdown_oxide",
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
    opts = {},
  },
  {
    "SmiteshP/nvim-navbuddy",
    config = function()
      local navbuddy = require("nvim-navbuddy")
      local actions = require("nvim-navbuddy.actions")

      navbuddy.setup({
        window = {
          border = "rounded", -- "rounded", "double", "solid", "none"
          -- or an array with eight chars building up the border in a clockwise fashion
          -- starting with the top-left corner. eg: { "╔", "═" ,"╗", "║", "╝", "═", "╚", "║" }.
          size = "60%", -- Or table format example: { height = "40%", width = "100%"}
          position = "50%", -- Or table format example: { row = "100%", col = "0%"}
          scrolloff = nil, -- scrolloff value within navbuddy window
          sections = {
            left = {
              size = "20%",
              border = nil, -- You can set border style for each section individually as well.
            },
            mid = {
              size = "40%",
              border = nil,
            },
            right = {
              -- No size option for right most section. It fills to
              -- remaining area.
              border = nil,
              preview = "leaf", -- Right section can show previews too.
              -- Options: "leaf", "always" or "never"
            },
          },
        },
        node_markers = {
          enabled = true,
          icons = {
            leaf = "  ",
            leaf_selected = " → ",
            branch = " ",
          },
        },
        icons = {
          File = "󰈙 ",
          Module = " ",
          Namespace = "󰌗 ",
          Package = " ",
          Class = "󰌗 ",
          Method = "󰆧 ",
          Property = " ",
          Field = " ",
          Constructor = " ",
          Enum = "󰕘",
          Interface = "󰕘",
          Function = "󰊕 ",
          Variable = "󰆧 ",
          Constant = "󰏿 ",
          String = " ",
          Number = "󰎠 ",
          Boolean = "◩ ",
          Array = "󰅪 ",
          Object = "󰅩 ",
          Key = "󰌋 ",
          Null = "󰟢 ",
          EnumMember = " ",
          Struct = "󰌗 ",
          Event = " ",
          Operator = "󰆕 ",
          TypeParameter = "󰊄 ",
        },
        use_default_mappings = true, -- If set to false, only mappings set
        -- by user are set. Else default
        -- mappings are used for keys
        -- that are not set by user
        mappings = {
          ["<esc>"] = actions.close(), -- Close and cursor to original location
          ["q"] = actions.close(),

          ["j"] = actions.next_sibling(), -- down
          ["k"] = actions.previous_sibling(), -- up

          ["h"] = actions.parent(), -- Move to left panel
          ["l"] = actions.children(), -- Move to right panel
          ["0"] = actions.root(), -- Move to first panel

          ["v"] = actions.visual_name(), -- Visual selection of name
          ["V"] = actions.visual_scope(), -- Visual selection of scope

          ["y"] = actions.yank_name(), -- Yank the name to system clipboard "+
          ["Y"] = actions.yank_scope(), -- Yank the scope to system clipboard "+

          ["i"] = actions.insert_name(), -- Insert at start of name
          ["I"] = actions.insert_scope(), -- Insert at start of scope

          ["a"] = actions.append_name(), -- Insert at end of name
          ["A"] = actions.append_scope(), -- Insert at end of scope

          ["r"] = actions.rename(), -- Rename currently focused symbol

          ["d"] = actions.delete(), -- Delete scope

          ["f"] = actions.fold_create(), -- Create fold of current scope
          ["F"] = actions.fold_delete(), -- Delete fold of current scope

          ["c"] = actions.comment(), -- Comment out current scope

          ["<enter>"] = actions.select(), -- Goto selected symbol
          ["o"] = actions.select(),

          ["J"] = actions.move_down(), -- Move focused node down
          ["K"] = actions.move_up(), -- Move focused node up

          ["s"] = actions.toggle_preview(), -- Show preview of current node

          ["<C-v>"] = actions.vsplit(), -- Open selected node in a vertical split
          ["<C-s>"] = actions.hsplit(), -- Open selected node in a horizontal split

          ["t"] = actions.telescope({ -- Fuzzy finder at current level.
            layout_config = { -- All options that can be
              height = 0.60, -- passed to telescope.nvim's
              width = 0.60, -- default can be passed here.
              prompt_position = "top",
              preview_width = 0.50,
            },
            layout_strategy = "horizontal",
          }),

          ["g?"] = actions.help(), -- Open mappings help window
        },
        lsp = {
          auto_attach = true, -- If set to true, you don't need to manually use attach function
          preference = nil, -- list of lsp server names in order of preference
        },
        source_buffer = {
          follow_node = true, -- Keep the current node in focus on the source buffer
          highlight = true, -- Highlight the currently focused node
          reorient = "smart", -- "smart", "top", "mid" or "none"
          scrolloff = nil, -- scrolloff value when navbuddy is open
        },
        custom_hl_group = nil, -- "Visual" or any other hl group to use instead of inverted colors
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "SmiteshP/nvim-navbuddy",
      dependencies = {
        "SmiteshP/nvim-navic",
        "MunifTanjim/nui.nvim",
      },
      opts = { lsp = { auto_attach = true } },
    },
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

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("reaper-lsp-attach", { clear = true }),
        callback = function(event)
          local keymap = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          keymap("gd", require("telescope.builtin").lsp_definitions, "[g]oto [d]efinition")
          keymap("gD", vim.lsp.buf.declaration, "[g]oto [D]eclaration")
          keymap("K", vim.lsp.buf.hover, "Hover Documentation")
          keymap("gI", require("telescope.builtin").lsp_implementations, "[g]oto [I]mplementation")
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
          keymap("<leader>li", "<cmd>LspInfo<cr>", "[l]sp [i]nfo")
          keymap("<leader>ca", vim.lsp.buf.code_action, "[c]ode [a]ctions")
          keymap("<leader>rn", vim.lsp.buf.rename, "[r]e[n]ame")
          keymap("<leader>ls", vim.lsp.buf.signature_help, "Signature Help")
          keymap("<leader>lq", vim.diagnostic.setloclist, "Diagnostic Local List")

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "cursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities =
        vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
      print(capabilities)

      local lspconfig = require("lspconfig")
      -- gopls
      lspconfig.gopls.setup({
        capabilities = capabilities,
        cmd = { "gopls", "-remote=auto" },
        debounce_text_changes = 1000,
        filetypes = {
          "go",
          "gomod",
          "gowork",
          "gotmpl",
        },
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
      })

      -- bashls
      lspconfig.bashls.setup({
        capabilities = capabilities,
        filetypes = {
          "zsh",
          "sh",
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
