{ self, inputs, ... }:
let
  username = "ben";
  hostname = "lab";
  addr = "${username}@${hostname}";
  systemStateVersion = "25.05";
in {
  flake.nixosConfigurations.${hostname} = inputs.nixos-raspberrypi.lib.nixosSystem {
    specialArgs = { inherit hostname username; };
    modules = [
      self.modules.nixos.core

      ({ pkgs, lib, ... }: {
        imports = with inputs.nixos-raspberrypi.nixosModules; [
          raspberry-pi-5.base
          raspberry-pi-5.bluetooth
          sd-image
        ];

        users.users.${username} = {
          initialPassword = "admin";
        };

        system.stateVersion = systemStateVersion;

        fileSystems."/mnt/ssd" = {
          device = "/dev/disk/by-label/storage";
          fsType = "ext4";
          options = [ "noatime" "nofail" ];
        };

        environment.etc."nextcloud-admin-pass".text = "202003195502";

        services.nextcloud = {
          enable = true;
          package = pkgs.nextcloud32;
          hostName = "lab";
          https = false;
          datadir = "/mnt/ssd/nextcloud";
          maxUploadSize = "10G";
          config = {
            dbtype = "sqlite";
            adminpassFile = "/etc/nextcloud-admin-pass";
            adminuser = "ben";
          };
          settings.trusted_domains = [ "lab" ];
        };

        networking.useNetworkd = true;
        networking.networkmanager.enable = true;

        services.gitea = {
          enable = true;
          database.type = "sqlite3";
          settings.service = {
            DISABLE_REGISTRATION = true;
            REQUIRE_SIGNIN_VIEW = true;
          };
        };

        networking.firewall = {
          allowedTCPPorts = [ 22 3000 80 443 ];
          allowedUDPPorts = [ 41641 ];
        };
      })
    ];
  };

  flake.homeConfigurations."${addr}" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.aarch64-linux;

    extraSpecialArgs = {
      inherit username hostname;
      inputs = builtins.removeAttrs inputs [ "self" ];
    };

    modules = with self.modules.homeManager; [
      core

      {
        home.username = username;
        home.homeDirectory = "/home/${username}";
      }
    ];
  };
}
