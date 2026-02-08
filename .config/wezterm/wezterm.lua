local wezterm = require("wezterm")
local config = wezterm.config_builder and wezterm.config_builder() or {}
config:set_strict_mode(true)

-- OS Detection
local target = wezterm.target_triple
local is_mac = target:find("darwin") ~= nil
local is_linux = target:find("linux") ~= nil

-- Core Settings
config.enable_wayland = false
config.color_scheme = "kanagawa (Gogh)"

-- Font Settings
config.font = wezterm.font({ family = "JetBrainsMono NF", stretch = "Normal" })
config.font_size = is_mac and 12 or 11
config.font_rules = {
    {
        italic = true,
        font = wezterm.font({
            family = "JetBrainsMono NF",
            style = "Italic",
            harfbuzz_features = { "calt=0", "liga=0", "clig=0" },
        }),
    },
    {
        italic = false,
        intensity = "Bold",
        font = wezterm.font({
            family = "JetBrainsMono NF",
            weight = "Bold",
            harfbuzz_features = { "calt=0", "liga=0", "clig=0" },
        }),
    },
    {
        font = wezterm.font({
            family = "JetBrainsMono NF",
            harfbuzz_features = { "calt=0", "liga=0", "clig=0" },
        }),
    },
}

-- Window
config.window_padding = { left = 8, right = 1, top = 1, bottom = 1 }
config.window_decorations = is_mac and "TITLE | RESIZE" or "RESIZE"
if is_mac then
    config.native_macos_fullscreen_mode = true
end

-- Scrollback and Cursor
config.scrollback_lines = 10000000
config.force_reverse_video_cursor = true
config.cursor_thickness = 2

-- Tab Bar
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.tab_max_width = 60
config.show_tab_index_in_tab_bar = true

-- Command Palette
config.command_palette_bg_color = "#111116"
config.command_palette_fg_color = "#dcd7ba"
config.command_palette_rows = 10
config.command_palette_font_size = 14

-- Updates
config.check_for_updates = true
config.check_for_updates_interval_seconds = 86400
config.show_update_window = true

-- Skip Confirmation
config.skip_close_confirmation_for_processes_named = { "bash", "sh", "zsh", "fish", "nu" }

-- Indices
config.tab_and_split_indices_are_zero_based = false

-- Launch Menu
if is_mac then
    config.launch_menu = {
        {
            label = "Dotfiles",
            args = { "zsh" },
            cwd = wezterm.home_dir .. "/.dotfiles",
        },
        {
            label = "Work",
            args = { "zsh" },
            cwd = wezterm.home_dir .. "/work/mac",
        },
    }
elseif is_linux then
    config.launch_menu = {
        {
            label = "Dotfiles",
            args = { "zsh" },
            cwd = wezterm.home_dir .. "/.dotfiles",
        },
        {
            label = "Infra",
            args = { "zsh" },
            cwd = wezterm.home_dir .. "/projects/infra",
        },
    }
end

-- Format Tab Title to Use CWD Name
wezterm.on("format-tab-title", function(tab)
    local pane = tab.active_pane
    local cwd_uri = pane.current_working_dir
    local dir_name = "?"
    if cwd_uri then
        local path = cwd_uri.file_path or cwd_uri:match("^file://([^?]+)")
        if path then
            dir_name = path:match("([^/\\]+)[/\\]*$") or path
        end
    end
    local index = tostring(tab.tab_index + 1)
    local bg_index_active = "#a9b1d6"
    local bg_name_active = "#1e1e2e"
    local bg_index_inactive = "#444b6a"
    local bg_name_inactive = "#1e1e2e"

    if tab.is_active then
        return {
            { Background = { Color = bg_index_active } },
            { Foreground = { Color = "#1e1e2e" } },
            { Text = " " .. index .. " " },
            { Background = { Color = bg_name_active } },
            { Foreground = { Color = "#c0caf5" } },
            { Text = " " .. dir_name .. " " },
        }
    else
        return {
            { Background = { Color = bg_index_inactive } },
            { Foreground = { Color = "#c0caf5" } },
            { Text = " " .. index .. " " },
            { Background = { Color = bg_name_inactive } },
            { Foreground = { Color = "#a9b1d6" } },
            { Text = " " .. dir_name .. " " },
        }
    end
end)

return config
