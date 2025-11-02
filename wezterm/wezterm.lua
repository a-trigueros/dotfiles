local wezterm = require("wezterm")

return {
	adjust_window_size_when_changing_font_size = false,
	color_scheme = "Catppuccin Macciato",
	enable_tab_bar = false,
	font_size = 16.0,
	font = wezterm.font("JetBrains Mono"),
	window_background_opacity = 0.8,
	mouse_bindings = {
		-- Ctrl-click will open the link under the mouse cursor
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "CTRL",
			action = wezterm.action.OpenLinkAtMouseCursor,
		},
	},
}
