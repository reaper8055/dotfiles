return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "williamboman/mason.nvim",
    "jay-babu/mason-nvim-dap.nvim",
    "nvim-neotest/nvim-nio",
    "rcarriga/nvim-dap-ui",
  },
  config = function()
    local adapters = {
      "delve",
    }

    require("mason").setup()
    require("mason-nvim-dap").setup({
      ensure_installed = adapters,
    })
    require("dapui").setup()
  end,
}
