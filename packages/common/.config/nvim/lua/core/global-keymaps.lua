local opts = {
    noremap = true, -- Disable recursive mapping evaluation to prevent infinite execution loops [Source: Vim help 'noremap']
    silent = true, -- Suppress command-line output when keymaps are executed [Source: Vim help 'silent']
}

-- Shorten function name
local keymap = vim.keymap.set -- Reference to Neovim Lua keymap mapping API [Source: Neovim Documentation 'vim.keymap.set']

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts) -- [Global/Noremap] Unbind default Space key behavior (move right) across all modes [Source: Vim help '<Nop>']
vim.g.mapleader = " " -- Set global leader key to Space [Source: Vim help 'mapleader']
vim.g.maplocalleader = " " -- Set buffer-local leader key to Space [Source: Vim help 'maplocalleader']

-- Write and Quit
-- [Normal Mode] <leader>wq -> Force-write current buffer to disk and close current window [Source: Vim help ':wq']
keymap("n", "<leader>wq", "<cmd>wq!<cr>", opts)

-- Write
-- [Normal Mode] <leader>w -> Force-write current buffer contents to disk [Source: Vim help ':w']
keymap("n", "<leader>w", "<cmd>w!<cr>", opts)

-- buffer delete
-- [Normal Mode] <leader>bd -> Delete active buffer from buffer list [Source: Vim help ':bdelete']
keymap("n", "<leader>bd", "<cmd>bd<cr>", opts)

-- Modes
--    normal_mode = "n",
--    insert_mode = "i",
--    visual_mode = "v",
--    visual_block_mode = "x",
--    term_mode = "t",
--    command_mode = "c",

-- Normal --
-- Better window navigation
-- [Normal Mode] Ctrl+h -> Move focus to the split window on the left [Source: Vim help 'CTRL-W_h']
keymap("n", "<C-h>", "<C-w>h", opts)
-- [Normal Mode] Ctrl+j -> Move focus to the split window below [Source: Vim help 'CTRL-W_j']
keymap("n", "<C-j>", "<C-w>j", opts)
-- [Normal Mode] Ctrl+k -> Move focus to the split window above [Source: Vim help 'CTRL-W_k']
keymap("n", "<C-k>", "<C-w>k", opts)
-- [Normal Mode] Ctrl+l -> Move focus to the split window on the right [Source: Vim help 'CTRL-W_l']
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize with h,j,k,l
-- [Normal Mode] Ctrl+Alt+k -> Expand current window height by 2 rows [Source: Vim help ':resize']
keymap("n", "<C-A-k>", "<cmd>resize +2<cr>", opts)
-- [Normal Mode] Ctrl+Alt+j -> Shrink current window height by 2 rows [Source: Vim help ':resize']
keymap("n", "<C-A-j>", "<cmd>resize -2<cr>", opts)
-- [Normal Mode] Ctrl+Alt+l -> Shrink current window width by 2 columns [Source: Vim help ':vertical-resize']
keymap("n", "<C-A-l>", "<cmd>vertical resize -2<cr>", opts)
-- [Normal Mode] Ctrl+Alt+h -> Expand current window width by 2 columns [Source: Vim help ':vertical-resize']
keymap("n", "<C-A-h>", "<cmd>vertical resize +2<cr>", opts)

-- Buffers
-- 1. Navigation
-- [Normal Mode] Shift+l -> Navigate to next open buffer [Source: Vim help ':bnext']
keymap("n", "<S-l>", "<cmd>bnext<cr>", opts)
-- [Normal Mode] Shift+h -> Navigate to previous open buffer [Source: Vim help ':bprevious']
keymap("n", "<S-h>", "<cmd>bprevious<cr>", opts)
-- 2. Control
-- [Normal Mode] <leader>bd -> Delete active buffer from buffer list (Note: Redundant re-declaration of <leader>bd) [Source: Vim help ':bdelete']
keymap("n", "<leader>bd", "<cmd>bd<cr>", opts)

-- Visual --
-- Stay in indent mode
-- [Visual Mode] < -> Shift visual selection left by 'shiftwidth', retaining visual selection [Source: Vim help 'gv', 'v_<']
keymap("v", "<", "<gv", opts)
-- [Visual Mode] > -> Shift visual selection right by 'shiftwidth', retaining visual selection [Source: Vim help 'gv', 'v_>']
keymap("v", ">", ">gv", opts)

-- Move text up and down
-- [Visual Mode] Alt+j -> Move visually selected lines down by 1 line, re-select selection, and auto-indent [Source: Vim help ':move', 'gv', '=']
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
-- [Visual Mode] Alt+k -> Move visually selected lines up by 2 lines relative to start mark, re-select selection, and auto-indent [Source: Vim help ':move', 'gv', '=']
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)
-- [Visual Mode] p -> Paste over selection into Black Hole Register ("_) to retain previous clipboard register contents [Source: Vim help 'quote_']
keymap("v", "p", '"_dP', opts)

-- Lazy
-- [Normal Mode] <leader>lz -> Open Lazy.nvim plugin manager UI [Source: lazy.nvim Documentation]
keymap("n", "<leader>lz", "<CMD>Lazy<cr>", opts)

-- tab management
-- [Normal Mode] <leader>ta -> Open a new tab page at the end of tablist [Source: Vim help ':tabnew']
keymap("n", "<leader>ta", "<cmd>$tabnew<cr>", opts)
-- [Normal Mode] <leader>tc -> Close current tab page [Source: Vim help ':tabclose']
keymap("n", "<leader>tc", "<cmd>tabclose<cr>", opts)
-- [Normal Mode] <leader>to -> Close all other tab pages except active tab [Source: Vim help ':tabonly']
keymap("n", "<leader>to", "<cmd>tabonly<cr>", opts)
-- [Normal Mode] <leader>tn -> Focus next tab page [Source: Vim help ':tabnext']
keymap("n", "<leader>tn", "<cmd>tabNext<cr>", opts)
-- [Normal Mode] <leader>tp -> Focus previous tab page [Source: Vim help ':tabprevious']
keymap("n", "<leader>tp", "<cmd>tabprevious<cr>", opts)
-- move current tab to previous position
-- [Normal Mode] <leader>- -> Move active tab page left by 1 position [Source: Vim help ':tabmove']
keymap("n", "<leader>-", "<cmd>-tabmove<cr>", opts)
-- move current tab to next position
-- [Normal Mode] <leader>+ -> Move active tab page right by 1 position [Source: Vim help ':tabmove']
keymap("n", "<leader>+", "<cmd>+tabmove<cr>", opts)

-- vertical split
-- [Normal Mode] <leader>| -> Create vertical window split [Source: Vim help ':vsplit']
keymap("n", "<leader>|", "<cmd>vsplit<cr>", opts)
-- horizontal split
-- [Normal Mode] <leader>_ -> Create horizontal window split [Source: Vim help ':split']
keymap("n", "<leader>_", "<cmd>split<cr>", opts)
