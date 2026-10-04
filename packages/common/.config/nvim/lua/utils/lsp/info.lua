-- :LspInfo, a buffer-focused summary built from public vim.lsp APIs only.
-- Rendered with the built-in "checkhealth" filetype, so `Heading ~` lines and
-- OK / WARNING markers are highlighted without any custom highlight code.
local M = {}

local function ok(msg) return "- ✅ OK " .. msg end
local function warn(msg) return "- ⚠️ WARNING " .. msg end

--- Checks that a config's command can be run. Function-valued cmds (RPC
--- clients) can't be inspected, so they are assumed fine.
local function cmd_status(cmd)
    if type(cmd) ~= "table" then return true, "<function>" end
    return vim.fn.executable(cmd[1]) == 1, cmd[1]
end

local function names(list)
    return table.concat(vim.tbl_map(function(item) return item.name end, list), ", ")
end

local function by_name(a, b) return a.name < b.name end

local function build(bufnr)
    local lines = {}
    local function add(s) vim.list_extend(lines, vim.split(s, "\n")) end
    local function section(title)
        if #lines > 0 then add("") end
        add(title .. " ~")
    end

    local ft = vim.bo[bufnr].filetype
    local attached = vim.lsp.get_clients({ bufnr = bufnr })

    section("Current buffer")
    local fname = vim.api.nvim_buf_get_name(bufnr)
    add(("- Buffer %d: %s"):format(bufnr, fname == "" and "[No Name]" or vim.fn.fnamemodify(fname, ":~:.")))
    add("- Filetype: " .. (ft == "" and "(none)" or ft))
    add(#attached > 0 and ok("Attached: " .. names(attached)) or warn("No clients attached"))

    if ft ~= "" then
        section(("Configurations for %s"):format(ft))
        local configs = vim.lsp.get_configs({ filetype = ft })
        table.sort(configs, by_name)
        if #configs == 0 then add("- None") end
        for _, config in ipairs(configs) do
            local runnable, exe = cmd_status(config.cmd)
            if not vim.lsp.is_enabled(config.name) then
                add(("- %s: not enabled"):format(config.name))
            elseif not runnable then
                add(warn(("%s: '%s' is not executable"):format(config.name, exe)))
            else
                add(ok(("%s: enabled"):format(config.name)))
            end
        end
    end

    section("Active clients")
    local clients = vim.lsp.get_clients()
    table.sort(clients, by_name)
    if #clients == 0 then add("- None") end
    for _, client in ipairs(clients) do
        local cmd = client.config.cmd
        add(("- %s (id: %d)"):format(client.name, client.id))
        add("  - Version: " .. (vim.tbl_get(client, "server_info", "version") or "?"))
        add("  - Root: " .. (client.root_dir and vim.fn.fnamemodify(client.root_dir, ":~") or "(none)"))
        add("  - Command: " .. (type(cmd) == "table" and table.concat(cmd, " ") or "<function>"))
        add("  - Encoding: " .. client.offset_encoding)
        add(
            "  - Buffers: "
                .. vim.iter(pairs(client.attached_buffers)):map(tostring):join(", ")
        )
    end

    section("Enabled configurations")
    local enabled = vim.lsp.get_configs({ enabled = true })
    table.sort(enabled, by_name)
    for _, config in ipairs(enabled) do
        local runnable, exe = cmd_status(config.cmd)
        local fts = table.concat(config.filetypes or {}, ", ")
        if runnable then
            add(("- %s: %s"):format(config.name, fts))
        else
            add(warn(("%s: '%s' is not executable"):format(config.name, exe)))
        end
    end

    section("Log")
    local log = vim.lsp.log
    local level = log.get_level()
    local level_name = log.levels[level]
    add(level < log.levels.WARN and warn("Level: " .. level_name .. " (slow, large log)") or ("- Level: " .. level_name))
    local path = log.get_filename()
    local stat = vim.uv.fs_stat(path)
    add(("- File: %s (%d KB)"):format(vim.fn.fnamemodify(path, ":~"), stat and stat.size / 1000 or 0))

    return lines
end

-- Same footprint as the Lazy window: 80% of the editor, centred.
local function layout()
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

function M.open()
    local lines = build(vim.api.nvim_get_current_buf())

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].bufhidden = "wipe"

    local win = vim.api.nvim_open_win(
        buf,
        true,
        vim.tbl_extend("force", layout(), { style = "minimal", title = " LSP Info ", title_pos = "center" })
    )
    -- After the window opens: the ftplugin sets window-local options (wrap etc.)
    -- on the current window.
    vim.bo[buf].filetype = "checkhealth"

    for _, key in ipairs({ "q", "<Esc>" }) do
        vim.keymap.set("n", key, "<cmd>close<cr>", { buffer = buf, nowait = true, desc = "Close LSP info" })
    end

    local group = vim.api.nvim_create_augroup("reaper-lsp-info", { clear = true })
    vim.api.nvim_create_autocmd("VimResized", {
        group = group,
        callback = function()
            if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_set_config(win, layout()) end
        end,
    })
    vim.api.nvim_create_autocmd("WinClosed", {
        group = group,
        pattern = tostring(win),
        once = true,
        callback = function() vim.api.nvim_del_augroup_by_id(group) end,
    })
end

return M
