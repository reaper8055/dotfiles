-- Set leader keys prior to registering mappings that reference <leader>
-- Setting mapleader after mapping <leader> binds prevents resolution to Space [K]
vim.g.mapleader = " "
-- Deliberately NOT " ". A localleader identical to leader means any plugin that
-- defines a <localleader> mapping collides with the <leader> tree.
vim.g.maplocalleader = "\\"

local default_opts = { silent = true }

---Wrapper around vim.keymap.set enforcing description injection and default silence.
---@param mode string|table Mode short-name ('n', 'v', 'x', etc.) or table of modes
---@param lhs string Key sequence
---@param rhs string|function Command string or Lua callback
---@param desc string Human-readable description registered to map metadata
---@param extra_opts? table Optional overrides (remap, expr, buffer, nowait)
local function map(mode, lhs, rhs, desc, extra_opts)
    local opts = vim.tbl_extend("force", default_opts, extra_opts or {})
    opts.desc = desc
    vim.keymap.set(mode, lhs, rhs, opts)
end

-- Leader Key Initialization
map("", "<Space>", "<Nop>", "Unbind default Space behavior")

-- Buffer Write & Quit
map("n", "<leader>w", "<cmd>w!<cr>", "Force-write buffer contents")

-- Window Navigation
map("n", "<C-h>", "<C-w>h", "Move focus to left split window")
map("n", "<C-j>", "<C-w>j", "Move focus to lower split window")
map("n", "<C-k>", "<C-w>k", "Move focus to upper split window")
map("n", "<C-l>", "<C-w>l", "Move focus to right split window")

-- Window Resizing
map("n", "<C-A-k>", "<cmd>resize +2<cr>", "Expand window height by 2 rows")
map("n", "<C-A-j>", "<cmd>resize -2<cr>", "Shrink window height by 2 rows")
map("n", "<C-A-l>", "<cmd>vertical resize -2<cr>", "Shrink window width by 2 columns")
map("n", "<C-A-h>", "<cmd>vertical resize +2<cr>", "Expand window width by 2 columns")

-- Buffer Navigation & Control
map("n", "<S-l>", "<cmd>bnext<cr>", "Navigate to next open buffer")
map("n", "<S-h>", "<cmd>bprevious<cr>", "Navigate to previous open buffer")
map("n", "<leader>bd", "<cmd>bd<cr>", "Delete active buffer from buffer list")

-- Visual Mode Indentation & Line Manipulation
map("v", "<", "<gv", "Shift selection left and retain visual selection")
map("v", ">", ">gv", "Shift selection right and retain visual selection")
map("v", "<A-j>", ":m '>+1<CR>gv=gv", "Move selection down 1 line and re-indent")
map("v", "<A-k>", ":m '<-2<CR>gv=gv", "Move selection up 1 line and re-indent")
map("v", "p", '"_dP', "Paste over selection without overwriting unnamed register")

-- Plugin Management
map("n", "<leader>lz", "<cmd>Lazy<cr>", "Open Lazy.nvim plugin manager UI")

-- Tab Management
map("n", "<leader>ta", "<cmd>$tabnew<cr>", "Open new tab page at end of tablist")
map("n", "<leader>tc", "<cmd>tabclose<cr>", "Close current tab page")
map("n", "<leader>to", "<cmd>tabonly<cr>", "Close other tab pages")
map("n", "<leader>tn", "<cmd>tabNext<cr>", "Focus next tab page")
map("n", "<leader>tp", "<cmd>tabprevious<cr>", "Focus previous tab page")
-- Under <leader>t with the rest of the tab commands. These were <leader>-/+,
-- but oil.nvim binds <space>- (== <leader>-) to its float toggle and, loading
-- later, won.
map("n", "<leader>t-", "<cmd>-tabmove<cr>", "Move active tab left by 1 position")
map("n", "<leader>t+", "<cmd>+tabmove<cr>", "Move active tab right by 1 position")

-- Window Splits
map("n", "<leader>|", "<cmd>vsplit<cr>", "Create vertical window split")
map("n", "<leader>_", "<cmd>split<cr>", "Create horizontal window split")
