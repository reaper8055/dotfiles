local function create_keymap_opts(bufnr, desc)
    return {
        desc = "nvim-tree: " .. desc,
        buffer = bufnr,
        noremap = true,
        silent = true,
        nowait = true,
    }
end

local function setup_keymaps(bufnr)
    local api = require("nvim-tree.api")
    local opts = function(desc) return create_keymap_opts(bufnr, desc) end

    -- start with upstream defaults
    api.map.on_attach.default(bufnr)

    -- remove defaults you do not use / want
    vim.keymap.del("n", "g?", { buffer = bufnr })
    vim.keymap.del("n", "<C-v>", { buffer = bufnr })
    vim.keymap.del("n", "<CR>", { buffer = bufnr })

    -- add vim-style navigation
    vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
    vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
    vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
    vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
    vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))

    -- optional opinionated overrides
    vim.keymap.set("n", "q", api.tree.close, opts("Close"))
end

return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local nvim_tree = require("nvim-tree")
        local api = require("nvim-tree.api")
        local helpers = require("utils.win.decorations")

        vim.api.nvim_create_autocmd("BufEnter", {
            nested = true,
            callback = function()
                if #vim.api.nvim_list_wins() ~= 1 then return end

                if api.tree.is_tree_buf(0) then vim.cmd.quit() end
            end,
        })

        nvim_tree.setup({
            on_attach = setup_keymaps,

            disable_netrw = true,
            hijack_netrw = true,

            sync_root_with_cwd = true,

            update_focused_file = {
                enable = true,
                update_root = {
                    enable = true,
                    ignore_list = {},
                },
            },

            view = {
                width = 40,
                side = "right",
                signcolumn = "yes",
                preserve_window_proportions = true,
                -- cursorline = true,
                -- cursorlineopt = "both",
            },

            renderer = {
                indent_markers = {
                    enable = true,
                    icons = helpers.indent_markers.icons,
                },
                icons = {
                    git_placement = "before",
                    symlink_arrow = "  ",
                    padding = {
                        icon = " ",
                        folder_arrow = " ",
                    },
                    show = {
                        file = true,
                        folder = true,
                        folder_arrow = true,
                        git = true,
                        modified = true,
                        diagnostics = true,
                        bookmarks = true,
                    },
                },
            },

            filters = {
                dotfiles = false,
                git_ignored = true,
            },

            git = {
                enable = true,
                timeout = 500,
                show_on_dirs = true,
                show_on_open_dirs = true,
            },

            actions = {
                open_file = {
                    quit_on_open = true,
                    window_picker = {
                        enable = false,
                    },
                },
            },
        })

        vim.api.nvim_set_hl(0, "NvimTreeCursorLine", {
            bg = "#2A2A37",
            bold = false,
        })

        vim.api.nvim_set_hl(0, "NvimTreeCursorLineNr", {
            fg = "#E6C384",
            bold = true,
        })

        vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeFindFileToggle!<cr>", {
            noremap = true,
            silent = true,
            desc = "Toggle nvim-tree on current file",
        })

        -- vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", {
        --     noremap = true,
        --     silent = true,
        --     desc = "Toggle nvim-tree",
        -- })
    end,
}
