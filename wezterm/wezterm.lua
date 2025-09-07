local wezterm = require 'wezterm'

local home = os.getenv("HOME")
local nushell_config_dir = home .. "/.config/nushell/" 

-- Fonction pour lancer Nushell via un shell login (Zsh) afin d'hériter de l'environnement
local function shell_command()
  return { 
	"/bin/zsh", 
	"-l", 
	"-c", 
	'exec /opt/homebrew/bin/nu'
  }
end


return {
	-- Shell à utiliser
	default_prog = shell_command(),
	adjust_window_size_when_changing_font_size = false,
	color_scheme = 'Catppuccin Mocha',
	enable_tab_bar = false,
	font_size = 16.0,
	font = wezterm.font('JetBrains Mono'),
	macos_window_background_blur = 30,
	window_background_opacity = 0.8,
	mouse_bindings = {
	  -- Ctrl-click will open the link under the mouse cursor
	  {
	    event = { Up = { streak = 1, button = 'Left' } },
	    mods = 'CTRL',
	    action = wezterm.action.OpenLinkAtMouseCursor,
	  },
	}
}