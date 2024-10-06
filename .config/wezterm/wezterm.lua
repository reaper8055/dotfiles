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
-- config.color_scheme = "Ayu Mirage"

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
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
config.tab_max_width = 60
config.font_size = 12
config.freetype_load_flags = "NO_HINTING"

config.window_padding = {
	left = 10,
	right = 10,
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
