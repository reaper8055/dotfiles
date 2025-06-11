local is_mac = vim.loop.os_uname().sysname == "Darwin"
local is_linux = vim.loop.os_uname().sysname == "Linux"

local function executable(cmd)
  return vim.fn.executable(cmd) == 1
end

if is_mac then
  vim.g.clipboard = {
    name = "macOS-clipboard",
    copy = {
      ["+"] = "pbcopy",
      ["*"] = "pbcopy",
    },
    paste = {
      ["+"] = "pbpaste",
      ["*"] = "pbpaste",
    },
  }
elseif is_linux then
  if executable("wl-copy") and executable("wl-paste") then
    vim.g.clipboard = {
      name = "Wayland-clipboard",
      copy = {
        ["+"] = { "wl-copy", "--type", "text/plain" },
        ["*"] = { "wl-copy", "--primary", "--type", "text/plain" },
      },
      paste = {
        ["+"] = { "wl-paste", "--no-newline" },
        ["*"] = { "wl-paste", "--no-newline", "--primary" },
      },
    }
  elseif executable("xclip") then
    vim.g.clipboard = {
      name = "X11-clipboard",
      copy = {
        ["+"] = { "xclip", "-selection", "clipboard" },
        ["*"] = { "xclip", "-selection", "primary" },
      },
      paste = {
        ["+"] = { "xclip", "-selection", "clipboard", "-o" },
        ["*"] = { "xclip", "-selection", "primary", "-o" },
      },
    }
  elseif executable("xsel") then
    vim.g.clipboard = {
      name = "X11-clipboard-xsel",
      copy = {
        ["+"] = { "xsel", "--clipboard", "--input" },
        ["*"] = { "xsel", "--primary", "--input" },
      },
      paste = {
        ["+"] = { "xsel", "--clipboard", "--output" },
        ["*"] = { "xsel", "--primary", "--output" },
      },
    }
  else
    vim.notify("No compatible clipboard utility found (xclip, wl-copy, or xsel)", vim.log.levels.WARN)
  end
end
