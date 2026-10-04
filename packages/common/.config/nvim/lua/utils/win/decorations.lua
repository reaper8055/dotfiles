local M = {}

-- Border style for every floating window. Applied globally via 'winborder'
-- (core/options.lua); only plugins that ignore 'winborder' reference this.
-- Try "single" for thin lines.
M.default_border = "bold"

M.telescope_dropdown_borders = {
    { "━", "┃", "━", "┃", "┏", "┓", "┛", "┗" },
    prompt = { "━", "┃", "━", "┃", "┏", "┓", "┃", "┃" },
    results = { "━", "┃", "━", "┃", "┣", "┫", "┛", "┗" },
    preview = { "━", "┃", "━", "┃", "┏", "┓", "┛", "┗" },
}

M.telescope_default_borders = {
    { "━", "┃", "━", "┃", "┏", "┓", "┛", "┗" },
    prompt = { "━", "┃", "━", "┃", "┏", "┓", "┛", "┗" },
    results = { "━", "┃", "━", "┃", "┏", "┓", "┛", "┗" },
    preview = { "━", "┃", "━", "┃", "┏", "┓", "┛", "┗" },
}

return M
