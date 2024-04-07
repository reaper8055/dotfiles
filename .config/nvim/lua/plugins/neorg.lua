return {
  "nvim-neorg/neorg",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "luarocks.nvim",
  },
  config = function()
    require("neorg").setup({
      load = {
        ["core.defaults"] = {},  -- Loads default behaviour
        ["core.concealer"] = {}, -- Adds pretty icons to your documents
        ["core.dirman"] = {      -- Manages Neorg workspaces
          config = {
            workspaces = {
              notes = "~/Notes",
            },
          },
        },
      },
    })
  end,
}
