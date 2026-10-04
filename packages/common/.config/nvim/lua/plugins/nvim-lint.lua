return {
    "mfussenegger/nvim-lint",
    config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
            sh = { "shellcheck" },
            bash = { "shellcheck" },
            zsh = { "shellcheck" },
        }

        -- Grouped so re-sourcing this file replaces the autocmd instead of
        -- stacking another copy on top of it.
        --
        -- BufEnter is deliberately absent: it fires on every window and buffer
        -- switch, re-linting buffers that have not changed. BufReadPost gives
        -- the same "lint on open" behaviour for a fraction of the work.
        vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
            group = vim.api.nvim_create_augroup("reaper-nvim-lint", { clear = true }),
            callback = function(event)
                if lint.linters_by_ft[vim.bo[event.buf].filetype] then lint.try_lint() end
            end,
        })

        -- Optional: Create a command to manually trigger linting
        vim.api.nvim_create_user_command("Lint", function() lint.try_lint() end, {})
    end,
}
