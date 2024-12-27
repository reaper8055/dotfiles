local opts = {
  noremap = true,
  silent = true,
}

-- Shorten function name
local keymap = vim.keymap.set

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Quit
keymap("n", "<leader>w", ":w!<CR>", opts)
keymap("n", "<leader>bd", ":bd<CR>", opts)

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize with h,j,k,l
keymap("n", "<C-A-k>", ":resize +2<CR>", opts)
keymap("n", "<C-A-j>", ":resize -2<CR>", opts)
keymap("n", "<C-A-l>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-A-h>", ":vertical resize +2<CR>", opts)

-- Buffers
-- 1. Navigation
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)
-- 2. Control
keymap("n", "<leader>bd", ":bd<CR>", opts)

-- Insert --
-- Press jk fast to enter
keymap("i", "jk", "<ESC>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Lazy
keymap("n", "<leader>lz", "<CMD>Lazy<CR>", opts)

-- tab management
keymap("n", "<leader>ta", ":$tabnew<CR>", opts)
keymap("n", "<leader>tc", ":tabclose<CR>", opts)
keymap("n", "<leader>to", ":tabonly<CR>", opts)
keymap("n", "<leader>tn", ":tabNext<CR>", opts)
keymap("n", "<leader>tp", ":tabprevious<CR>", opts)
-- move current tab to previous position
keymap("n", "<leader>-", ":-tabmove<CR>", opts)
-- move current tab to next position
keymap("n", "<leader>+", ":+tabmove<CR>", opts)

-- vertical split
keymap("n", "<leader>|", ":vsplit<CR>", opts)
-- horizontal split
keymap("n", "<leader>_", ":split<CR>", opts)
