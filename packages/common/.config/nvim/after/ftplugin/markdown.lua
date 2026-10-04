-- This file is an ftplugin: Neovim already sources it once per markdown buffer.
-- Wrapping the setting in a global BufRead/BufNewFile autocmd (as this used to)
-- registered a *new, ungrouped* autocmd every time a markdown buffer was opened,
-- so they accumulated for the lifetime of the session.
vim.opt_local.spell = true
