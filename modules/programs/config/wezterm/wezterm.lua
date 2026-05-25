      local wezterm = require("wezterm")

      local config = {
      	window_decorations = "RESIZE",
      	audible_bell = "Disabled",
      	color_scheme = "Afterglow (Gogh)",
      	hide_tab_bar_if_only_one_tab = true,
      	use_fancy_tab_bar = false,
      font = wezterm.font("Hurmit Nerd Font"),
        default_prog = { "tmux", "new-session" },
      }

      return config
 
