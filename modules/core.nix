{
  flake.modules.nixos.core = { hostname, ... }: {
    
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nixpkgs.config.allowUnfree = true;
    
    # Audio (PipeWire)
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Bluetooth
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;
    
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
