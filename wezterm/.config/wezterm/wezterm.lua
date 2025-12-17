local wezterm = require("wezterm")
local config = wezterm.config_builder()

config = {
	automatically_reload_config = true,
	enable_tab_bar = false,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE",
	window_padding = {
		left = 20,
		right = 20,
		top = 20,
		bottom = 5,
	},
	color_scheme = "rose-pine",
	window_background_opacity = 0.7,
	macos_window_background_blur = 50,
}

config.font = wezterm.font({
	family = "JetBrains Mono",
	weight = "Regular",
	stretch = "Normal",
	style = "Normal",
})
config.font_size = 18.0

return config
