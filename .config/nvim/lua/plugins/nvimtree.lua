-- Local helpers
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

  local keymaps = {
    -- Navigation
    { mode = "n", key = "l", action = api.node.open.edit, desc = "Open" },
    { mode = "n", key = "h", action = api.node.navigate.parent_close, desc = "Close Directory" },
    { mode = "n", key = "v", action = api.node.open.vertical, desc = "Open: Vertical Split" },
    { mode = "n", key = "<CR>", action = api.node.open.edit, desc = "Open" },
    { mode = "n", key = "P", action = api.node.navigate.parent, desc = "Parent Directory" },

    -- File operations
    { mode = "n", key = "a", action = api.fs.create, desc = "Create" },
    { mode = "n", key = "d", action = api.fs.remove, desc = "Delete" },
    { mode = "n", key = "r", action = api.fs.rename, desc = "Rename" },
    { mode = "n", key = "x", action = api.fs.cut, desc = "Cut" },
    { mode = "n", key = "c", action = api.fs.copy.node, desc = "Copy" },
    { mode = "n", key = "p", action = api.fs.paste, desc = "Paste" },

    -- Tree operations
    { mode = "n", key = "R", action = api.tree.reload, desc = "Refresh" },
    { mode = "n", key = "?", action = api.tree.toggle_help, desc = "Help" },
    { mode = "n", key = "q", action = api.tree.close, desc = "Close" },

    -- Filters and toggles
    { mode = "n", key = "H", action = api.tree.toggle_hidden_filter, desc = "Toggle Dotfiles" },
    {
      mode = "n",
      key = "I",
      action = api.tree.toggle_gitignore_filter,
      desc = "Toggle Git Ignore",
    },
  }

  -- Apply keymaps
  for _, map in ipairs(keymaps) do
    vim.keymap.set(map.mode, map.key, map.action, opts(map.desc))
  end
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
    local helpers = require("utils.win.decorations")

    -- Setup autoclose behavior
    vim.api.nvim_create_autocmd("BufEnter", {
      nested = true,
      callback = function()
        if
          #vim.api.nvim_list_wins() == 1
          and vim.api.nvim_buf_get_name(0):match("NvimTree_") ~= nil
        then
          vim.cmd("quit")
        end
      end,
    })

    nvim_tree.setup({
      on_attach = setup_keymaps,
      disable_netrw = true,
      hijack_netrw = true,
      update_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = false,
      },
      view = {
        width = 40,
        side = "right",
        signcolumn = "yes",
      },
      renderer = {
        indent_markers = {
          enable = true,
          icons = helpers.indent_markers.icons,
        },
        icons = {
          git_placement = "before",
          padding = " ",
          symlink_arrow = "  ",
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
        },
      },
      filters = {
        dotfiles = false,
      },
      git = {
        enable = true,
        ignore = true,
        timeout = 500,
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

    -- Global keymaps
    vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { noremap = true, silent = true })
  end,
}
