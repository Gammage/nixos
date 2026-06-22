local wezterm = require("wezterm")
local act = wezterm.action

local config = {
    copy_on_select = true,
    window_decorations = "RESIZE",
    audible_bell = "Disabled",
    color_scheme = "Afterglow (Gogh)",
    hide_tab_bar_if_only_one_tab = true,
    use_fancy_tab_bar = false,
    font = wezterm.font("Hurmit Nerd Font"),
    default_prog = { "tmux", "new-session" },

    keys = {  -- enabling ctrl/shift/alt + Enter/Tab

        -- "AppCursorMode" == send to applications (neovim) only, not terminal input

        {   -- C-Enter sends <F33>
            key = 'Enter', mods = 'CTRL',
            action = act.SendString("\x1b[20;5~"), -- keycodes found with `infocmp` command
            when = "AppCursorMode"
        },
        {   -- S-Enter sends <F34>
            key = 'Enter', mods = 'SHIFT',
            action = act.SendString("\x1b[21;5~"),
            when = "AppCursorMode"
        },
        {   -- M-Enter sends <F35>
            key = 'Enter', mods = 'ALT',
            action = act.SendString("\x1b[23;5~"),
            when = "AppCursorMode"
        },

        {   -- C-Tab sends <F30>
            key = 'Tab', mods = 'CTRL',
            action = act.SendString("\x1b[17;5~"),
            when = "AppCursorMode"
        },
        {   -- S-Tab sends <F31>
            key = 'Tab', mods = 'SHIFT',
            action = act.SendString("\x1b[18;5~"),
            when = "AppCursorMode"
        },
        {   -- M-Tab sends <F32>
            key = 'Tab', mods = 'ALT',
            action = act.SendString("\x1b[19;5~"),
            when = "AppCursorMode"
        },
    }
}

return config

