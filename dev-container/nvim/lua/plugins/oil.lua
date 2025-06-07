return {
  "stevearc/oil.nvim",
  opts = {},
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("oil").setup({
      cleanup_delay_ms = 500,
      columns = { "icon" },
      keymaps = {
        ["<C-h>"] = false,
        ["<M-h>"] = "actions.select_split",
      },
      float = {
        border = require("utils.win.decorations").default_border,
      },
      confirmation = {
        border = require("utils.win.decorations").default_border,
      },
      ssh = {
        border = require("utils.win.decorations").default_border,
      },
      progress = {
        border = require("utils.win.decorations").default_border,
      },
      keymaps_help = {
        border = require("utils.win.decorations").default_border,
      },
      view_options = {
        show_hidden = true,
      },
    })

    -- Open parent directory in current window
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

    -- Open parent directory in floating window
    vim.keymap.set("n", "<space>-", require("oil").toggle_float)
  end,
}
