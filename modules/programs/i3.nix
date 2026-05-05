{ flake.modules.homeManager.i3 = { pkgs, ... }: {
  home.packages = with pkgs; [ dmenu i3 i3status ];
  home.file.".config/i3/config".text = ''
    set $mod Mod1
    terminal wezterm

    bindsym $mod+d exec dmenu_run
    bindsym $mod+Return exec wezterm
    bindsym $mod+Shift+q kill
    bindsym $mod+Shift+e exec i3-msg exit

    bar {
      status_command ${pkgs.i3status}/bin/i3status
    }
  '';
}; }
