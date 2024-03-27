return {
  "dnlhc/glance.nvim",
  config = function()
    require("glance").setup()

    --keymaps
    -- local keymap = vim.api.nvim_set_keymap
    -- local opts = {
    --   noremap = true,
    --   silent = true,
    -- }
    -- keymap("n", "gD", "<CMD>Glance definitions<CR>")
    -- keymap("n", "gR", "<CMD>Glance references<CR>")
    -- keymap("n", "gY", "<CMD>Glance type_definitions<CR>")
    -- keymap("n", "gM", "<CMD>Glance implementations<CR>")
  end,
}
