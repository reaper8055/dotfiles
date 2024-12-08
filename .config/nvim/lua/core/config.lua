-- Set default floating window border with sharp corners
local default_border = {
  { "┌", "FloatBorder" },
  { "─", "FloatBorder" },
  { "┐", "FloatBorder" },
  { "│", "FloatBorder" },
  { "┘", "FloatBorder" },
  { "─", "FloatBorder" },
  { "└", "FloatBorder" },
  { "│", "FloatBorder" },
}

-- Set default options for floating windows
local opt = { noremap = true, silent = true }
vim.api.nvim_set_option("winblend", 0)
vim.opt.pumblend = 0

-- Override the default floating window configuration
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Configure LSP hover
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = default_border,
    })

    -- Configure LSP signature help
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = default_border,
    })
  end,
})

-- Override the default new float window function for plenary
local ok, win = pcall(require, "plenary.window.float")
if ok then
  local old_create = win.create
  win.create = function(opts, ...)
    if not opts then opts = {} end
    opts.border = opts.border or default_border
    return old_create(opts, ...)
  end
end

-- Configure completion menu if nvim-cmp is installed
local cmp_ok, cmp = pcall(require, "cmp")
if cmp_ok then
  cmp.setup({
    window = {
      completion = {
        border = default_border,
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
      },
      documentation = {
        border = default_border,
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
      },
    },
  })
end

-- Configure telescope borders if telescope is installed
local telescope_ok, telescope = pcall(require, "telescope")
if telescope_ok then
  telescope.setup({
    defaults = {
      borderchars = {
        prompt = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        results = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      },
    },
  })
end

-- Test command for notifications
vim.api.nvim_create_user_command("TestNotify", function()
  local notify = require("mini.notify").make_notify()

  notify("This is an info message", vim.log.levels.INFO, {
    title = "Info",
  })

  vim.defer_fn(
    function()
      notify("This is a warning message", vim.log.levels.WARN, {
        title = "Warning",
      })
    end,
    1000
  )

  vim.defer_fn(
    function()
      notify("This is an error message", vim.log.levels.ERROR, {
        title = "Error",
      })
    end,
    2000
  )
end, {})

return default_border
