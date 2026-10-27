{
  # NIX OS
  flake.modules.nixos.graphical = { pkgs, ... }: {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    services.xserver = {
      enable = true;
      displayManager.lightdm.enable = true;
      xkb = {
        layout = "gb";
        options = "altwin:super_win";
      };
    };

    services.libinput.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = "*";
    };

    fonts.packages = with pkgs; [
      nerd-fonts.hurmit
      roboto
    ];
  };

  # HOME - MANAGER
  flake.modules.homeManager.graphical = { pkgs, lib, hostname, ... }:
  let
    commonPackages = with pkgs; [
      arandr
      dmenu
      firefox
      maim
      i3
      i3status
      polybarFull
      wezterm
    ];
    desktopPackages = with pkgs; [
      discord
      gimp
      obsidian
      google-chrome
      tor-browser
      imagemagick
      zoom-us
      wineWow64Packages.stable
    ];
  in {
    home.packages = commonPackages ++ lib.optionals (hostname == "desktop") desktopPackages;

    home.file = {
      ".config/wezterm/wezterm.lua".text = builtins.readFile ./programs/config/wezterm/wezterm.lua;
    };
  };
}
