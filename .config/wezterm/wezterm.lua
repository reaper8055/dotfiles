-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
  config:set_strict_mode(true)
end

-- This is where you actually apply your config choices
-- config.color_scheme = "Ayu Mirage"

config.command_palette_bg_color = "#111116"
config.command_palette_fg_color = "#dcd7ba"
config.command_palette_rows = 10
config.command_palette_font_size = 12
config.window_frame = {
  font = wezterm.font({
    family = "FiraCode Nerd Font",
    weight = 450,
  }),
}

-- config.default_prog = { "tmux" }
config.scrollback_lines = 1000000
config.force_reverse_video_cursor = true
config.color_scheme = "kanagawa (Gogh)"
config.enable_tab_bar = true
config.font = wezterm.font({
  family = "FiraCode Nerd Font",
  weight = 450,
})
config.font_rules = {
  {
    italic = true,
    font = wezterm.font({
      family = "JetBrainsMono Nerd Font",
      style = "Italic",
    }),
  },
  {
    italic = false,
    intensity = "Bold",
    font = wezterm.font({
      family = "FiraCode Nerd Font",
    }),
  },
}
config.enable_wayland = false
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
config.tab_max_width = 60
-- config.font_size = 12
-- config.freetype_load_flags = "NO_HINTING"

config.window_padding = {
  left = 8,
  right = 5,
  top = 1,
  bottom = 1,
}
config.window_decorations = "RESIZE"
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
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
