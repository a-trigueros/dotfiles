local wezterm = require("wezterm")

local config = {
	adjust_window_size_when_changing_font_size = false,
	color_scheme = "Catppuccin Mocha",
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

-- macOS spécifique
if wezterm.target_triple:find("apple") then
	-- Fonction pour lancer Nushell via un shell login (Zsh) afin d'hériter de l'environnement
	local function shell_command()
		return {
			"/bin/zsh",
			"-l",
			"-c",
			"exec /opt/homebrew/bin/nu",
		}
	end

	config.default_prog = shell_command()
	config.macos_window_background_blur = 30
end

-- Windows spécifique
if wezterm.target_triple:find("windows") then
	-- Mets à jour ce chemin si nécessaire
	local nu_path = wezterm.home_dir .. "\\AppData\\Local\\Programs\\nu\\bin\\nu.exe"
	config.default_prog = { nu_path }
	config.prefer_egl = true
end

return config

