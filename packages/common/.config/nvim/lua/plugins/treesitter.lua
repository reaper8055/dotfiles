return {
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

                -- Bail out unless a parser actually exists for this filetype.
                -- Previously the pcall was discarded and 'indentexpr' was set
                -- regardless, pointing parser-less buffers at an indent function
                -- that can never work.
                if not pcall(vim.treesitter.start, buf) then return end

                -- Enable treesitter-based indentation (except yaml)
                if ft ~= "yaml" then
                    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })
    end,
}
