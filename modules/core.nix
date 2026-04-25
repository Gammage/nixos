{
  flake.modules.nixos.core = { hostname, ... }: {

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    services.xserver = {
        enable = true;
        displayManager.lightdm.enable = true;
        desktopManager.xfce.enable = true;

        xkb = {
            layout = "gb";
            options = "";
            };
        };
    

    time.timeZone = "America/New_York";
    i18n.defaultLocale = "en_US.UTF-8";

    networking.hostName = hostname;
    networking.networkmanager.enable = true;

    security.sudo.wheelNeedsPassword = false;

  };
}
