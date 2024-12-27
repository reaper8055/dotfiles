-- lua/utils/lsp/lspinfo.lua
local M = {}

-- Function to get LSP information for a buffer
local function get_lsp_info(bufnr)
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  local lines = {
    "Language Server Protocol (LSP) Info",
    "==============================================================================",
    "",
    "LSP configs active in this session (globally) ~",
    -- Get all configured servers
    "- Configured servers: "
      .. table.concat(
        vim.tbl_map(function(client) return client.name end, vim.lsp.get_active_clients()),
        ", "
      ),
    "- OK Deprecated servers: (none)",
    "",
    string.format("LSP configs active in this buffer (bufnr: %d) ~", bufnr),
    string.format("- Language client log: %s", vim.lsp.get_log_path()),
    string.format("- Detected filetype: `%s`", vim.bo[bufnr].filetype),
    string.format("- %d client(s) attached to this buffer", #clients),
  }

  -- Add client-specific information
  for _, client in ipairs(clients) do
    table.insert(
      lines,
      string.format("- Client: `%s` (id: %d, bufnr: [%d])", client.name, client.id, bufnr)
    )
    table.insert(lines, string.format("  root directory:    %s", client.config.root_dir or ""))
    table.insert(
      lines,
      string.format("  filetypes:         %s", table.concat(client.config.filetypes or {}, ", "))
    )
    table.insert(
      lines,
      string.format(
        "  cmd:               %s",
        client.config.cmd and table.concat(client.config.cmd, " ") or ""
      )
    )
    if client.version then
      table.insert(lines, string.format("  version:          `%s`", client.version))
    end
    table.insert(
      lines,
      string.format(
        "  executable:        %s",
        tostring(vim.fn.executable(client.config.cmd and client.config.cmd[1] or "") == 1)
      )
    )
    table.insert(lines, string.format("  autostart:         %s", tostring(client.config.autostart)))
  end

  return lines
end

-- Function to create floating window with LSP info
function M.create_float()
  -- Get info for current buffer
  local current_buf = vim.api.nvim_get_current_buf()
  local lines = get_lsp_info(current_buf)

  -- Create floating window
  local width = vim.api.nvim_get_option("columns")
  local height = vim.api.nvim_get_option("lines")
  local win_width = math.floor(width * 0.8)
  local win_height = math.floor(height * 0.8)
  local row = math.floor((height - win_height) / 2)
  local col = math.floor((width - win_width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win_opts = {
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    style = "minimal",
    border = require("utils.win.decorations").default_border,
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)

  -- Set the content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Add highlighting
  local ns_id = vim.api.nvim_create_namespace("LspInfoFloat")
  vim.api.nvim_buf_add_highlight(buf, ns_id, "Title", 0, 0, -1)

  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

  -- Add keymapping to close the window
  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", {
    noremap = true,
    silent = true,
  })
end

-- Export the module
return M
