{ flake.modules.homeManager.i3 = { pkgs, ... }: {
  xsession.enable = true;
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = "wezterm";
      keybindings = {
        "$mod+d" = "exec dmenu_run";
        "$mod+Return" = "exec wezterm";
        "$mod+Shift+q" = "kill";
        "$mod+Shift+e" = "exec i3-msg exit";
      };
      bars = [{ statusCommand = "${pkgs.i3status}/bin/i3status"; }];
    };
  };
}; }
