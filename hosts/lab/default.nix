{ self, inputs, ... }:
let
  username = "ben";
  hostname = "lab";
  addr = "${username}@${hostname}";
  system = "aarch64-linux";
  systemStateVersion = "25.05";
in {
  flake.nixosConfigurations.${hostname} = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit hostname username; nixos-raspberrypi = inputs.nixos-raspberrypi; };
    modules = with self.modules.nixos; [
      core

      ({ pkgs, lib, ... }: {
        nixpkgs.hostPlatform.system = system;
        system.stateVersion = systemStateVersion;

        imports = [
          inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
          inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.bluetooth
          inputs.nixos-raspberrypi.nixosModules.sd-image
        ];

        networking.useNetworkd = true;
        networking.networkmanager.enable = false;

        services.tailscale.enable = true;

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
    pkgs = inputs.nixpkgs.legacyPackages.${system};

    extraSpecialArgs = {
      inherit username hostname;
      inputs = builtins.removeAttrs inputs [ "self" ];
    };

    modules = with self.modules.homeManager; [
      core

      {
        home.stateVersion = "25.05";
        home.username = username;
        home.homeDirectory = "/home/${username}";
      }
    ];
  };
}
