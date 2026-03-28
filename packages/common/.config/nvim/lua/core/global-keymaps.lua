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

-- Write and Quit
keymap("n", "<leader>wq", "<cmd>wq!<cr>", opts)

-- Write
keymap("n", "<leader>w", "<cmd>w!<cr>", opts)

-- buffer delete
keymap("n", "<leader>bd", "<cmd>bd<cr>", opts)

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
keymap("n", "<C-A-k>", "<cmd>resize +2<cr>", opts)
keymap("n", "<C-A-j>", "<cmd>resize -2<cr>", opts)
keymap("n", "<C-A-l>", "<cmd>vertical resize -2<cr>", opts)
keymap("n", "<C-A-h>", "<cmd>vertical resize +2<cr>", opts)

-- Buffers
-- 1. Navigation
keymap("n", "<S-l>", "<cmd>bnext<cr>", opts)
keymap("n", "<S-h>", "<cmd>bprevious<cr>", opts)
-- 2. Control
keymap("n", "<leader>bd", "<cmd>bd<cr>", opts)

-- Insert --
-- Press jk fast to enter
keymap("i", "jk", "<ESC>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<A-j>", "<cmd>m .+1<cr>==", opts)
keymap("v", "<A-k>", "<cmd>m .-2<cr>==", opts)
keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", "<cmd>move '>+1<cr>gv-gv", opts)
keymap("x", "K", "<cmd>move '<-2<cr>gv-gv", opts)
keymap("x", "<A-j>", "<cmd>move '>+1<cr>gv-gv", opts)
keymap("x", "<A-k>", "<cmd>move '<-2<cr>gv-gv", opts)

-- Lazy
keymap("n", "<leader>lz", "<CMD>Lazy<cr>", opts)

-- tab management
keymap("n", "<leader>ta", "<cmd>$tabnew<cr>", opts)
keymap("n", "<leader>tc", "<cmd>tabclose<cr>", opts)
keymap("n", "<leader>to", "<cmd>tabonly<cr>", opts)
keymap("n", "<leader>tn", "<cmd>tabNext<cr>", opts)
keymap("n", "<leader>tp", "<cmd>tabprevious<cr>", opts)
-- move current tab to previous position
keymap("n", "<leader>-", "<cmd>-tabmove<cr>", opts)
-- move current tab to next position
keymap("n", "<leader>+", "<cmd>+tabmove<cr>", opts)

-- vertical split
keymap("n", "<leader>|", "<cmd>vsplit<cr>", opts)
-- horizontal split
keymap("n", "<leader>_", "<cmd>split<cr>", opts)
