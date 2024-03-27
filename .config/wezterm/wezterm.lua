-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices
config.color_scheme = "Ayu Mirage"
config.font = wezterm.font({ family = "FiraCode Nerd Font" })
config.font = wezterm.font_with_fallback({
  "FiraCode Nerd Font",
})
config.font_rules = {
  {
    intensity = "Bold",
    italic = true,
    font = wezterm.font({
      family = "JetBrains Mono",
      weight = "Bold",
      style = "Italic",
    }),
  },
  {
    italic = true,
    intensity = "Half",
    font = wezterm.font({
      family = "JetBrains Mono",
      weight = "DemiBold",
      style = "Italic",
    }),
  },
  {
    italic = true,
    intensity = "Normal",
    font = wezterm.font({
      family = "JetBrains Mono",
      style = "Italic",
    }),
  },
}

config.window_padding = {
  left = 1,
  right = 1,
  top = 1,
  bottom = 1,
}
config.window_decorations = "RESIZE"
config.enable_tab_bar = false
config.cursor_thickness = 2
config.check_for_updates = true
config.check_for_updates_interval_seconds = 86400
config.show_update_window = true
config.skip_close_confirmation_for_processes_named = {
  "bash",
  "sh",
  "zsh",
  "fish",
  "tmux",
  "nu",
  "cmd.exe",
  "pwsh.exe",
  "powershell.exe",
}

-- and finally, return the configuration to wezterm
return config
