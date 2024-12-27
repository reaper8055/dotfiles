-- Override the default new float window function for plenary

local helpers = require("utils.win.decorations")

local ok, win = pcall(require, "plenary.window.float")
if ok then
  local old_create = win.create

  win.create = function(opts, ...)
    if not opts then opts = {} end
    opts.border = opts.border or helpers.default_border
    return old_create(opts, ...)
  end
end

-- Override the default floating window utility function
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or helpers.default_border
  opts.max_width = math.floor(vim.api.nvim_get_option("columns") * 0.6)
  opts.max_height = math.floor(vim.api.nvim_get_option("lines") * 0.4)

  -- Create the floating window
  local bufnr, winnr = orig_util_open_floating_preview(contents, syntax, opts, ...)

  -- Enable word wrap and remove line break padding
  vim.api.nvim_win_set_option(winnr, "wrap", true)
  vim.api.nvim_win_set_option(winnr, "linebreak", true) -- Wrap at word boundaries
  vim.api.nvim_win_set_option(winnr, "breakindent", true) -- Preserve indentation when wrapping

  return bufnr, winnr
end
