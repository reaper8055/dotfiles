-- Function to keep cursor in the lower third of the screen
local function keep_cursor_lower_third()
    local height = vim.fn.winheight(0)
    local third = math.floor(height / 3)
    local target_line = height - third

    -- Get the current cursor position
    local cursor_line = vim.fn.winline()

    -- Calculate the number of lines to scroll
    local scroll_amount = cursor_line - target_line

    -- Scroll the view
    if scroll_amount > 0 then
        vim.cmd("normal! " .. scroll_amount .. "<C-e>")
    elseif scroll_amount < 0 then
        vim.cmd("normal! " .. -scroll_amount .. "<C-y>")
    end
end

-- Map k and j to move and adjust the view, preserving count
vim.keymap.set("n", "k", function()
    local count = vim.v.count1
    vim.cmd("normal! " .. count .. "k")
    keep_cursor_lower_third()
end, { silent = true })

vim.keymap.set("n", "j", function()
    local count = vim.v.count1
    vim.cmd("normal! " .. count .. "j")
    keep_cursor_lower_third()
end, { silent = true })

-- Optional: Apply the function to other movement commands
vim.keymap.set("n", "<C-u>", function()
    vim.cmd("normal! <C-u>")
    keep_cursor_lower_third()
end, { silent = true })

vim.keymap.set("n", "<C-d>", function()
    vim.cmd("normal! <C-d>")
    keep_cursor_lower_third()
end, { silent = true })

vim.keymap.set("n", "gg", function()
    vim.cmd("normal! gg")
    keep_cursor_lower_third()
end, { silent = true })

vim.keymap.set("n", "G", function()
    vim.cmd("normal! G")
    keep_cursor_lower_third()
end, { silent = true })
