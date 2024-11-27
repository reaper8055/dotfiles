return {
  "folke/which-key.nvim",
  delay = 100,
  opts = {
    preset = "classic",
    win = {
      border = "single",
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
