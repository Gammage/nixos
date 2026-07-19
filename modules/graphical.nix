{
  # NIX OS
  flake.modules.nixos.graphical = { pkgs, ... }: {
    security.rtkit.enable = true;

    boot.supportedFilesystems = [ "davfs" ];

    fileSystems."/home/ben/nextcloud" = {
      device = "http://lab/remote.php/dav/files/ben/";
      fsType = "davfs";
      options = [ "noauto" "user" "_netdev" ];
    };

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
    ];
  };

  # HOME - MANAGER
  flake.modules.homeManager.graphical = { pkgs, ... }: {
    home.packages = with pkgs; [
      davfs2
      arandr
      dmenu
      discord
      firefox
      gimp
      maim
      obsidian
      obs-studio
      google-chrome
      tor-browser
      i3
      i3status
      polybarFull
      wezterm
      imagemagick
      zoom-us
      wineWow64Packages.stable
    ];

    home.file = {
      ".config/wezterm/wezterm.lua".text = builtins.readFile ./programs/config/wezterm/wezterm.lua;
    };
  };
}
