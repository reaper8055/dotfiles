local wezterm = require("wezterm")
local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
  config:set_strict_mode(true)
end

-- Core Settings
config.enable_wayland = false
config.color_scheme = "kanagawa (Gogh)"

-- Font Settings
config.font = wezterm.font({ family = "JetBrainsMono NF", stretch = "Normal" })
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
config.font_size = 10

-- Window
config.window_padding = { left = 8, right = 1, top = 1, bottom = 1 }
config.window_decorations = "RESIZE"

-- Scrollback and Cursor
config.scrollback_lines = 10000000
config.force_reverse_video_cursor = true
config.cursor_thickness = 2

-- Tab Bar
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 60
config.show_tab_index_in_tab_bar = true

-- Command Palette
config.command_palette_bg_color = "#111116"
config.command_palette_fg_color = "#dcd7ba"
config.command_palette_rows = 10
config.command_palette_font_size = 12

-- Updates
config.check_for_updates = true
config.check_for_updates_interval_seconds = 86400
config.show_update_window = true

-- Skip Confirmation
config.skip_close_confirmation_for_processes_named = { "bash", "sh", "zsh", "fish", "nu" }

-- Indices
config.tab_and_split_indices_are_zero_based = false

-- Leader Key
config.leader = { key = " ", mods = "CTRL", timeout_milliseconds = 1000 }

-- Launch Menu
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

-- Helper function to get the current SSH command
local function get_current_ssh_command(pane)
  local process_info = pane:get_foreground_process_info()
  if not process_info then
    return nil
  end

  -- Check if SSH is running
  if process_info.name == "ssh" then
    -- Extract the full command including arguments
    local success, stdout, stderr = wezterm.run_child_process({
      "ps",
      "-p",
      tostring(process_info.pid),
      "-o",
      "args=",
    })

    if success then
      -- Return the full SSH command
      return stdout:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
    end
  end

  return nil
end

-- Key Bindings
config.keys = {
  -- Modified split key bindings that preserve SSH context
  {
    key = "\\",
    mods = "LEADER",
    action = wezterm.action_callback(function(window, pane)
      local ssh_cmd = get_current_ssh_command(pane)
      if ssh_cmd then
        -- Split and spawn the same SSH command
        window:perform_action(
          wezterm.action.SplitHorizontal({
            args = { "bash", "-c", ssh_cmd },
          }),
          pane
        )
      else
        -- Default behavior
        window:perform_action(wezterm.action.SplitHorizontal, pane)
      end
    end),
  },
  {
    key = "-",
    mods = "LEADER",
    action = wezterm.action_callback(function(window, pane)
      local ssh_cmd = get_current_ssh_command(pane)
      if ssh_cmd then
        -- Split and spawn the same SSH command
        window:perform_action(
          wezterm.action.SplitVertical({
            args = { "bash", "-c", ssh_cmd },
          }),
          pane
        )
      else
        -- Default behavior
        window:perform_action(wezterm.action.SplitVertical, pane)
      end
    end),
  },
  -- Original key bindings
  { key = "c", mods = "LEADER", action = wezterm.action.SpawnCommandInNewTab({ cwd = "$CWD" }) },
  { key = "h", mods = "CTRL", action = wezterm.action.ActivatePaneDirection("Left") },
  { key = "j", mods = "CTRL", action = wezterm.action.ActivatePaneDirection("Down") },
  { key = "k", mods = "CTRL", action = wezterm.action.ActivatePaneDirection("Up") },
  { key = "l", mods = "CTRL", action = wezterm.action.ActivatePaneDirection("Right") },
  { key = "h", mods = "ALT", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
  { key = "j", mods = "ALT", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },
  { key = "k", mods = "ALT", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
  { key = "l", mods = "ALT", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },
  { key = "n", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
  { key = "p", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },
  { key = "R", mods = "LEADER", action = wezterm.action.ReloadConfiguration },
  { key = "[", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
  { key = "]", mods = "LEADER", action = wezterm.action.PasteFrom("Clipboard") },
  { key = "1", mods = "LEADER", action = wezterm.action.ActivateTab(0) },
  { key = "2", mods = "LEADER", action = wezterm.action.ActivateTab(1) },
  { key = "3", mods = "LEADER", action = wezterm.action.ActivateTab(2) },
  { key = "4", mods = "LEADER", action = wezterm.action.ActivateTab(3) },
  { key = "5", mods = "LEADER", action = wezterm.action.ActivateTab(4) },
  { key = "6", mods = "LEADER", action = wezterm.action.ActivateTab(5) },
  { key = "7", mods = "LEADER", action = wezterm.action.ActivateTab(6) },
  { key = "8", mods = "LEADER", action = wezterm.action.ActivateTab(7) },
  { key = "9", mods = "LEADER", action = wezterm.action.ActivateTab(8) },
  { key = "x", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
  { key = "f", mods = "LEADER", action = wezterm.action.ToggleFullScreen },
  { key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState },
  { key = "k", mods = "LEADER", action = wezterm.action.ClearScrollback("ScrollbackOnly") },
  { key = "l", mods = "LEADER", action = wezterm.action.ActivateLastTab },
  { key = "s", mods = "LEADER", action = wezterm.action.ShowTabNavigator },
  { key = "S", mods = "LEADER", action = wezterm.action.ShowLauncher },
  { key = "f", mods = "CTRL|SHIFT", action = wezterm.action.Search("CurrentSelectionOrEmptyString") },
}

-- Unix Domain Persistence
config.unix_domains = { { name = "unix" } }
config.default_gui_startup_args = { "connect", "unix" }

-- Format Tab Title to Use CWD Name
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
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

  -- Define background colors
  local bg_index_active = "#a9b1d6" -- Light bluish (index)
  local bg_name_active = "#1e1e2e" -- Dark (name)

  local bg_index_inactive = "#444b6a"
  local bg_name_inactive = "#1e1e2e"

  if tab.is_active then
    return {
      -- Index block
      { Background = { Color = bg_index_active } },
      { Foreground = { Color = "#1e1e2e" } },
      { Text = " " .. index .. " " },

      -- Name block
      { Background = { Color = bg_name_active } },
      { Foreground = { Color = "#c0caf5" } },
      { Text = " " .. dir_name .. " " },
    }
  else
    return {
      -- Index block
      { Background = { Color = bg_index_inactive } },
      { Foreground = { Color = "#c0caf5" } },
      { Text = " " .. index .. " " },

      -- Name block
      { Background = { Color = bg_name_inactive } },
      { Foreground = { Color = "#a9b1d6" } },
      { Text = " " .. dir_name .. " " },
    }
  end
end)

return config
