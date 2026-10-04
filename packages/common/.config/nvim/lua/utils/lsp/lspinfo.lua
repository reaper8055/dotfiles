-- lua/utils/lsp/lspinfo.lua
local M = {}

-- Function to get LSP information for a buffer
local function get_lsp_info(bufnr)
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    local lines = {
        "Language Server Protocol (LSP) Info",
        "==============================================================================",
        "",
        "LSP configs active in this session (globally) ~",
        -- Get all configured servers
        "- Configured servers: "
            .. table.concat(
                vim.tbl_map(function(client) return client.name end, vim.lsp.get_clients()),
                ", "
            ),
        "- OK Deprecated servers: (none)",
        "",
        string.format("LSP configs active in this buffer (bufnr: %d) ~", bufnr),
        string.format("- Language client log: %s", vim.lsp.log.get_filename()),
        string.format("- Detected filetype: `%s`", vim.bo[bufnr].filetype),
        string.format("- %d client(s) attached to this buffer", #clients),
    }

    -- Add client-specific information
    for _, client in ipairs(clients) do
        table.insert(
            lines,
            string.format("- Client: `%s` (id: %d, bufnr: [%d])", client.name, client.id, bufnr)
        )
        -- `client.root_dir` is the canonical field under the vim.lsp.config API
        table.insert(lines, string.format("  root directory:    %s", client.root_dir or ""))
        table.insert(
            lines,
            string.format(
                "  filetypes:         %s",
                table.concat(client.config.filetypes or {}, ", ")
            )
        )
        table.insert(
            lines,
            string.format(
                "  cmd:               %s",
                type(client.config.cmd) == "table" and table.concat(client.config.cmd, " ")
                    or tostring(client.config.cmd)
            )
        )
        if client.version then
            table.insert(lines, string.format("  version:          `%s`", client.version))
        end
        table.insert(
            lines,
            string.format(
                "  executable:        %s",
                tostring(
                    type(client.config.cmd) == "table"
                        and vim.fn.executable(client.config.cmd[1]) == 1
                )
            )
        )
    end

    return lines
end

-- Function to create floating window with LSP info
function M.create_float()
    -- Get info for current buffer
    local current_buf = vim.api.nvim_get_current_buf()
    local lines = get_lsp_info(current_buf)

    -- Create floating window
    local width = vim.o.columns
    local height = vim.o.lines
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
    }

    local win = vim.api.nvim_open_win(buf, true, win_opts)

    -- Set the content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Add highlighting
    local ns_id = vim.api.nvim_create_namespace("LspInfoFloat")
    vim.hl.range(buf, ns_id, "Title", { 0, 0 }, { 0, -1 })

    -- Set buffer options
    vim.bo[buf].modifiable = false
    vim.bo[buf].bufhidden = "wipe"

    -- Add keymapping to close the window
    vim.keymap.set("n", "q", function()
        if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    end, { buffer = buf, noremap = true, silent = true, desc = "Close LSP info" })
end

-- Export the module
return M
