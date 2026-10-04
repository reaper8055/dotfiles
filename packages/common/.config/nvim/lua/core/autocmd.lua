vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("reaper-highlight-yank", { clear = true }),
    callback = function() vim.hl.on_yank() end,
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

-- :checkhealth's float (vim.g.health.style = "float") opens at a fixed 80
-- columns and stays visible while the checks run. Instead: as soon as it names
-- its buffer "health://" (before any check or redraw), size it like the Lazy
-- window and hide it; show it once the report is done (filetype is set last).
local function health_layout()
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    return {
        relative = "editor",
        anchor = "NW",
        width = width,
        height = height,
        col = math.floor((vim.o.columns - width) / 2),
        row = math.floor((vim.o.lines - height) / 2),
    }
end

local function health_float(buf)
    local win = vim.fn.bufwinid(buf)
    if win ~= -1 and vim.api.nvim_win_get_config(win).relative ~= "" then return win end
end

local health_group = vim.api.nvim_create_augroup("reaper-health-float", { clear = true })
vim.api.nvim_create_autocmd("BufFilePost", {
    group = health_group,
    pattern = "health://",
    callback = function(event)
        local win = health_float(event.buf)
        if win then vim.api.nvim_win_set_config(win, vim.tbl_extend("force", health_layout(), { hide = true })) end
    end,
})
vim.api.nvim_create_autocmd("FileType", {
    group = health_group,
    pattern = "checkhealth",
    callback = function(event)
        local win = health_float(event.buf)
        if win then vim.api.nvim_win_set_config(win, { hide = false }) end
    end,
})
vim.api.nvim_create_autocmd("VimResized", {
    group = health_group,
    callback = function()
        local win = health_float(vim.fn.bufnr("health://"))
        if win then vim.api.nvim_win_set_config(win, health_layout()) end
    end,
})
