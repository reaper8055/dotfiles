-- =============================================================================
-- 1. System Clipboard (OSC 52)
-- =============================================================================
-- OSC 52 is only used when there is no local clipboard to talk to, i.e. over
-- SSH. It was previously set unconditionally, which broke pasting *into* Neovim
-- on this machine:
--
--   Terminals essentially never honour OSC 52 clipboard *reads* (it would let
--   any program exfiltrate your clipboard), so the paste handler below falls
--   back to the unnamed register. But 'clipboard=unnamedplus' has already
--   aliased unnamed to "+, so "+p just read back whatever Neovim last yanked
--   and the real system clipboard never reached the editor.
--
-- Locally, leaving vim.g.clipboard unset lets Neovim find pbcopy/pbpaste (macOS)
-- or wl-copy/xclip (Linux) by itself, and "+ works in both directions.
if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
    local osc52 = require("vim.ui.clipboard.osc52")

    -- Best effort: see the note above about OSC 52 reads.
    local function osc52_paste()
        return {
            vim.fn.split(vim.fn.getreg(""), "\n"),
            vim.fn.getregtype(""),
        }
    end

    vim.g.clipboard = {
        name = "OSC 52",
        copy = {
            ["+"] = osc52.copy("+"),
            ["*"] = osc52.copy("*"),
        },
        paste = {
            ["+"] = osc52_paste,
            ["*"] = osc52_paste,
        },
    }
end

-- =============================================================================
-- 2. Scalar & Primitive Options (Declarative Map)
-- =============================================================================
local options = {
    -- Backup & Swap Files
    backup = false,
    writebackup = false,
    swapfile = false,
    undofile = true,

    -- Command Line & Menus
    cmdheight = 1,
    pumheight = 10,
    showtabline = 2,
    completeopt = { "menuone", "noselect" },

    -- Search & Matching
    hlsearch = true,
    ignorecase = true,
    smartcase = true,

    -- Window Splits
    splitbelow = true,
    splitright = true,
    winblend = 0,
    winborder = require("utils.win.decorations").default_border,

    -- Cursor & Line Display
    cursorline = true,
    cursorlineopt = "both",
    cursorcolumn = true,
    number = true,
    relativenumber = true,
    numberwidth = 4,
    signcolumn = "yes",
    wrap = true,
    scrolloff = 8,
    sidescrolloff = 8,
    colorcolumn = "100",
    textwidth = 80,
    conceallevel = 0,

    -- Indentation Defaults (Fallback when .editorconfig is absent)
    autoindent = true,
    smartindent = true,
    expandtab = true,
    shiftwidth = 4,
    tabstop = 4,
    softtabstop = 4,

    -- Filesystem & Timing
    fileformats = "unix,dos,mac",
    endofline = true,
    fixendofline = true,
    timeoutlen = 1000,
    updatetime = 300,
    mouse = "a",
    termguicolors = true,
    clipboard = "unnamedplus",
    guifont = "JetBrainsMono NF",
}

for opt, val in pairs(options) do
    vim.opt[opt] = val
end

-- =============================================================================
-- 3. Compound, Flag, and Character-Map Options
-- =============================================================================
-- Message Suppression: suppress intro message ('I'), ins-completion ('c'), and search counts ('S')
vim.opt.shortmess:append({ I = true, c = true, S = true })

-- Whitespace Visibility
vim.opt.list = true
vim.opt.listchars = {
    tab = "» ",
    trail = "·",
    eol = "¬",
}

-- UI Fill Characters (fold column, window boundaries, end-of-buffer)
vim.opt.fillchars = {
    eob = " ",
    fold = " ",
    foldopen = " ",
    foldsep = " ",
    foldclose = " ",
}

--- Allow specified keys that move the cursor left/right to move to the previous/next line when the cursor is on the first/last character
--- <,> = left and right arrow keys
--- [,] = cursor keys in insert mode
--- h,l = h and l keys in normal mode
vim.cmd("set whichwrap+=<,>,[,],h,l")

-- Floats and popup menus share the editor background, with a visible border.
-- Links only (no colour values), so this follows whichever colorscheme is
-- loaded. Registered before `colorscheme` so it also applies on startup.
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("reaper-float-colors", { clear = true }),
    callback = function()
        vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
        vim.api.nvim_set_hl(0, "Pmenu", { link = "Normal" })
        vim.api.nvim_set_hl(0, "FloatBorder", { link = "Comment" })
        -- These default to fill groups (Pmenu/NormalFloat), not FloatBorder.
        for _, group in ipairs({ "PmenuBorder", "BlinkCmpMenuBorder", "BlinkCmpDocBorder", "BlinkCmpSignatureHelpBorder" }) do
            vim.api.nvim_set_hl(0, group, { link = "FloatBorder" })
        end
    end,
})

-- Built-in colorscheme (ships with Neovim 0.12).
vim.cmd.colorscheme("catppuccin")
