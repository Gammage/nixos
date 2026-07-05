{
  flake.modules.homeManager.graphical = { pkgs, ... }: {
    home.packages = with pkgs; [
      arandr
      dmenu
      discord
      firefox
      gimp
      maim
      obsidian
      obs-studio
      google-chrome
      i3
      i3status
      polybarFull
      wezterm
      imagemagick
      zoom-us
    ];

    home.file = {
      ".config/wezterm/wezterm.lua".text = builtins.readFile ./programs/config/wezterm/wezterm.lua;
    };
  };
}
