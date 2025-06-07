return {
  "kevinhwang91/nvim-ufo",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "kevinhwang91/promise-async",
  },
  config = function()
    vim.o.foldcolumn = "0"
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    require("ufo").setup({
      provider_selector = function(bufnr, filetype, buftype) return { "treesitter", "indent" } end,
    })
  end,
}
