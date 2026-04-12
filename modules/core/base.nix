{
  flake.modules.nixos.base = { hostname, ... }: {

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    time.timeZone = "America/New_York";
    i18n.defaultLocale = "en_US.UTF-8";

    networking.hostName = hostname;
    networking.useDHCP = true;

    security.sudo.wheelNeedsPassword = false;

  };
}
