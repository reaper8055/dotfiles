return {
  "rcarriga/nvim-notify",
  config = function()
    require("notify").setup({
      minimum_width = 50,
      background_color = "#282C34",
      render = "default",
      stages = "static",
      timeout = 1000,
      fps = 60,
    })
  end,
}
