-- Set default colorscheme
vim.cmd("colorscheme default")

-- Set the background
vim.opt.background = "dark" -- or 'light'

-- Basic highlight groups
vim.cmd([[
  highlight Normal guibg=NONE ctermbg=NONE
  highlight NonText guifg=#808080 ctermfg=244
  highlight CursorLine guibg=#2C2C2C ctermbg=236
  highlight LineNr guifg=#707070 ctermfg=242
]])

require("core.global-keymaps")
require("core.lazy")
require("core.options")
require("core.autocmd")
require("core.config")
require("core.view-port")
