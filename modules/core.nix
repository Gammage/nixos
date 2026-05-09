{
  flake.modules.nixos.core = { pkgs, hostname, ... }: {
    
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nixpkgs.config.allowUnfree = true;

    # Make libstdc++.so.6 findable for pip/uv installed Python packages (e.g. numpy)
    environment.sessionVariables = {
      LD_LIBRARY_PATH = with pkgs; [
        "${stdenv.cc.cc.lib}/lib"
        "${zlib}/lib"
      ];
    };
    
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
        libinput.enable = true;

        xkb = {
            layout = "gb";
            options = "altwin:super_win";
            };
        };
    

    time.timeZone = "Europe/London";
    i18n.defaultLocale = "en_GB.UTF-8";

    networking.hostName = hostname;
    networking.networkmanager.enable = true;

    security.sudo.wheelNeedsPassword = false;

  };
}
