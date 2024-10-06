return {
  {
    "mfussenegger/nvim-lint",
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        zsh = { "shellcheck" },
      }

      -- Set up autocommands for linting
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
        callback = function() lint.try_lint() end,
      })

      -- Optional: Create a command to manually trigger linting
      vim.api.nvim_create_user_command("Lint", function() lint.try_lint() end, {})
    end,
  },
}
