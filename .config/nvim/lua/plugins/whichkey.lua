return {
  "folke/which-key.nvim",
  delay = 100,
  opts = {
    preset = "classic",
    win = {
      title = false,
      border = require("utils.win.decorations").default_border,
    },
    icons = {
      mappings = false,
    },
  },
  key = {
    {
      "<leader>?",
      function() require("which-key").show({ global = false }) end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
