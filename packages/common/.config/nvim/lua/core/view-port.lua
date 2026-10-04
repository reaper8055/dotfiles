-- =============================================================================
-- Viewport / scroll behaviour
-- =============================================================================
--
-- READ THIS BEFORE KEEPING IT ENABLED.
--
-- Every `vim.cmd("normal! ...<C-e>")` style call in this file was broken: inside
-- a `:normal!` argument, "<C-e>" is six literal characters (<, C, -, e, >), NOT
-- the control key. Vim parsed `3<C` as the `<` operator followed by an invalid
-- motion, aborted, and discarded the rest. Two consequences:
--
--   1. keep_cursor_lower_third() never scrolled anything. The "keep the cursor
--      in the lower third" behaviour has NEVER actually run on this config.
--   2. <C-u> and <C-d> were completely dead keys -- `normal! <C-u>` aborted the
--      same way, so half-page scrolling did nothing at all.
--
-- Fixing (2) is unambiguously correct. Fixing (1) turns on a behaviour you have
-- never experienced, and it is a fairly aggressive one: it forces a redraw that
-- pins the cursor to ~2/3 down the window on every j/k. If that feels wrong,
-- flip the flag below to false -- <C-u>/<C-d>/j/k all keep working, they just
-- stop yanking the viewport around.
local KEEP_CURSOR_LOWER_THIRD = true

-- Real terminal codes, resolved once. This is what the old string literals were
-- supposed to be.
local CTRL_E = vim.api.nvim_replace_termcodes("<C-e>", true, false, true)
local CTRL_Y = vim.api.nvim_replace_termcodes("<C-y>", true, false, true)
local CTRL_U = vim.api.nvim_replace_termcodes("<C-u>", true, false, true)
local CTRL_D = vim.api.nvim_replace_termcodes("<C-d>", true, false, true)

-- Function to keep cursor in the lower third of the screen
local function keep_cursor_lower_third()
    if not KEEP_CURSOR_LOWER_THIRD then return end
    if vim.bo.buftype ~= "" then return end

    local height = vim.fn.winheight(0)
    local third = math.floor(height / 3)
    local target_line = height - third

    -- Get the current cursor position
    local cursor_line = vim.fn.winline()

    -- Calculate the number of lines to scroll
    local scroll_amount = cursor_line - target_line

    -- Scroll the view
    if scroll_amount > 0 then
        -- was: vim.cmd("normal! " .. scroll_amount .. "<C-e>")  -- literal chars, no-op
        vim.cmd("normal! " .. scroll_amount .. CTRL_E)
    elseif scroll_amount < 0 then
        -- was: vim.cmd("normal! " .. -scroll_amount .. "<C-y>")  -- literal chars, no-op
        vim.cmd("normal! " .. -scroll_amount .. CTRL_Y)
    end
end

-- Map k and j to move and adjust the view, preserving count
-- (these two were fine: "j" and "k" are literal characters anyway)
vim.keymap.set("n", "k", function()
    local count = vim.v.count1
    vim.cmd("normal! " .. count .. "k")
    keep_cursor_lower_third()
end, { silent = true, desc = "Up, keeping cursor in lower third" })

vim.keymap.set("n", "j", function()
    local count = vim.v.count1
    vim.cmd("normal! " .. count .. "j")
    keep_cursor_lower_third()
end, { silent = true, desc = "Down, keeping cursor in lower third" })

-- These two were the dead keys. Counts are honoured now as well.
vim.keymap.set("n", "<C-u>", function()
    -- was: vim.cmd("normal! <C-u>")  -- literal chars; <C-u> did nothing at all
    vim.cmd("normal! " .. vim.v.count1 .. CTRL_U)
    keep_cursor_lower_third()
end, { silent = true, desc = "Half page up" })

vim.keymap.set("n", "<C-d>", function()
    -- was: vim.cmd("normal! <C-d>")  -- literal chars; <C-d> did nothing at all
    vim.cmd("normal! " .. vim.v.count1 .. CTRL_D)
    keep_cursor_lower_third()
end, { silent = true, desc = "Half page down" })

vim.keymap.set("n", "gg", function()
    vim.cmd("normal! gg")
    keep_cursor_lower_third()
end, { silent = true, desc = "Top of buffer" })

vim.keymap.set("n", "G", function()
    vim.cmd("normal! G")
    keep_cursor_lower_third()
end, { silent = true, desc = "Bottom of buffer" })
