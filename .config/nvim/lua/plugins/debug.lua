return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "leoluz/nvim-dap-go",
        "mfussenegger/nvim-dap",
        "nvim-neotest/nvim-nio",
    },
    config = function()
        vim.keymap.set("n", "<leader>dc", function() require("dap").continue() end)
        vim.keymap.set("n", "<Leader>dt", function() require("dap").toggle_breakpoint() end)

        require("dapui").setup()
        require("dap-go").setup()

        local dap, dapui = require("dap"), require("dapui")
        dap.listeners.before.attach.dapui_config = function() dapui.open() end
        dap.listeners.before.launch.dapui_config = function() dapui.open() end
        dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
        dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
    end,
}
