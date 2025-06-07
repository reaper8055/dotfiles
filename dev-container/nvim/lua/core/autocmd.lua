vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("reaper-highlight-yank", { clear = true }),
  callback = function() vim.highlight.on_yank() end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "help", "man" },
  command = "wincmd L",
})

vim.api.nvim_create_autocmd("CmdwinEnter", {
  callback = function()
    local opts = { buffer = true, noremap = true }

    -- Word motions
    vim.keymap.set("n", "w", "w", opts)
    vim.keymap.set("n", "b", "b", opts)
    vim.keymap.set("n", "e", "e", opts)
    vim.keymap.set("n", "W", "W", opts)
    vim.keymap.set("n", "B", "B", opts)
    vim.keymap.set("n", "E", "E", opts)

    -- Line navigation
    vim.keymap.set("n", "$", "$", opts)
    vim.keymap.set("n", "0", "0", opts)
    vim.keymap.set("n", "^", "^", opts)

    -- Vertical motions
    vim.keymap.set("n", "j", "j", opts)
    vim.keymap.set("n", "k", "k", opts)
    vim.keymap.set("n", "gg", "gg", opts)
    vim.keymap.set("n", "G", "G", opts)

    -- Character find/till
    vim.keymap.set("n", "f", "f", opts)
    vim.keymap.set("n", "F", "F", opts)
    vim.keymap.set("n", "t", "t", opts)
    vim.keymap.set("n", "T", "T", opts)
    vim.keymap.set("n", ";", ";", opts)
    vim.keymap.set("n", ",", ",", opts)

    -- Paragraph motions
    vim.keymap.set("n", "{", "{", opts)
    vim.keymap.set("n", "}", "}", opts)
  end,
})

-- Fix floating window borders for retro box theme
vim.api.nvim_set_option("winblend", 0)
vim.opt.winblend = 0

-- Configure floating window appearance
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    -- Remove or customize borders for floating windows
    vim.api.nvim_set_hl(0, "FloatBorder", { link = "Normal" })
    vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })

    -- Set border characters to empty or spaces if you want no visible border
    vim.opt.fillchars:append("eob: ")
    vim.opt.fillchars:append("fold: ")
    vim.opt.fillchars:append("foldopen: ")
    vim.opt.fillchars:append("foldsep: ")
    vim.opt.fillchars:append("foldclose: ")
  end,
})
