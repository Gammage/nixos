{
  flake.modules.homeManager.graphical = { pkgs, ... }: {
    home.packages = with pkgs; [
      arandr
      dmenu
      discord
      firefox
      gimp
      google-chrome
      i3
      i3status
      wezterm
    ];

    home.file = {
      ".config/wezterm/wezterm.lua".text = builtins.readFile ./programs/config/wezterm/wezterm.lua;
    };
  };
}
