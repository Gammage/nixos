{ flake.modules.homeManager.i3 = { pkgs, ... }: {
  home.packages = with pkgs; [ dmenu i3 i3status ];
  home.file.".config/i3/config".source = pkgs.writeText "i3-config" ''
    terminal wezterm

    bindsym Mod1+d exec dmenu_run
    bindsym Mod1+Return exec wezterm
    bindsym Mod1+Shift+q kill
    bindsym Mod1+Shift+e exec i3-msg exit

    bar {
      status_command ${pkgs.i3status}/bin/i3status
    }
  '';
}; }
