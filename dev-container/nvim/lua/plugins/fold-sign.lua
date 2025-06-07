return {
  "yaocccc/nvim-foldsign",
  config = function()
    require("nvim-foldsign").setup({
      offset = -4,
      foldsigns = {
        open = "", -- mark the beginning of a fold
        close = "", -- show a closed fold
        seps = { "", "" },
        -- seps = { "│", "│" }, -- open fold middle marker
      },
    })
  end,
}
