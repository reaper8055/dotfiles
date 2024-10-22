return {
  "folke/which-key.nvim",
  dependencies = {
    "echasnovski/mini.icons",
    version = false,
  },
  delay = 100,
  opts = {
    preset = "classic",
    win = {
      border = "single",
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
