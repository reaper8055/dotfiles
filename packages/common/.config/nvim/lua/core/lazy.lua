-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        lazyrepo,
        lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- mapleader/maplocalleader are set in core/global-keymaps.lua, which
-- core/init.lua requires before this file -- so they are already correct by the
-- time lazy.setup() runs. They used to be set in both places with *different*
-- localleader values, and whichever file loaded last silently won.
--
-- termguicolors stays here: it has to be on before the colorscheme loads, and
-- core/options.lua runs after lazy.setup().
vim.opt.termguicolors = true

-- Disabling netrw so that 'oil' can take it's place
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local installed, lazy = pcall(require, "lazy")
if not installed then return end

local helpers = require("utils.win.decorations")

lazy.setup({
    spec = {
        { import = "plugins" },
    },
    install = { colorscheme = { "default" } },
    checker = {
        enabled = true,
        notify = false,
    },
    rocks = {
        enabled = true,
        root = vim.fn.stdpath("data") .. "/lazy-rocks",
        server = "https://nvim-neorocks.github.io/rocks-binaries/",
        hererocks = false,
    },
    change_detection = {
        notify = false,
    },
    ui = {
        backdrop = 100,
        border = helpers.default_border,
    },
})
