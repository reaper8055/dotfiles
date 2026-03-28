local M = {}

M.default_border = {
    { "┏", "FloatBorder" },
    { "━", "FloatBorder" },
    { "┓", "FloatBorder" },
    { "┃", "FloatBorder" },
    { "┛", "FloatBorder" },
    { "━", "FloatBorder" },
    { "┗", "FloatBorder" },
    { "┃", "FloatBorder" },
}

M.indent_markers = {
    icons = {
        corner = "┗",
        edge = "┃",
        item = "┃",
        bottom = "━",
        none = " ",
    },
}

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

M.border_icons = {
    corner = {
        top = {
            left = "┏",
            right = "┓",
            none = " ",
        },
        bottom = {
            left = "┗",
            right = "┛",
            none = " ",
        },
    },
    side = {
        horizontal = "━",
        vertical = "┃",
        none = " ",
    },
    joins = {
        left = "┣",
        right = "┫",
        none = " ",
    },
}
return M
