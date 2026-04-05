return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        -- event = { "BufReadPost", "BufNewFile" },
        config = function()
            local ts = require("nvim-treesitter")

            -- Optional: customize install directory (defaults to stdpath('data')/site)
            ts.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })

            -- Install parsers (no-op if already installed)
            ts.install({
                "lua",
                "cpp",
                "vim",
                "vimdoc",
                "rust",
                "go",
                "java",
                "nix",
                "gitcommit",
                "gitignore",
                "json",
                "yaml",
                "bash",
                "regex",
                "markdown",
                "markdown_inline",
                "svelte",
                "typescript",
                "javascript",
                "html",
                "css",
                "scss",
                "vue",
                "swift",
                "proto",
            })

            -- Enable highlighting and indentation via FileType autocmd
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("reaper-treesitter", { clear = true }),
                callback = function(event)
                    local buf = event.buf
                    local ft = event.match

                    -- Attempt to start treesitter highlighting
                    -- This silently fails if no parser exists for the filetype
                    pcall(vim.treesitter.start, buf)

                    -- Enable treesitter-based indentation (except yaml)
                    if ft ~= "yaml" then
                        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        init = function()
            -- Disable entire built-in ftplugin mappings to avoid conflicts.
            -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
            vim.g.no_plugin_maps = true

            -- Or, disable per filetype (add as you like)
            -- vim.g.no_python_maps = true
            -- vim.g.no_ruby_maps = true
            -- vim.g.no_rust_maps = true
            -- vim.g.no_go_maps = true
        end,
        config = function()
            -- put your config here
        end,
    },
}
