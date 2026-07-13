{ self, inputs, ... }:
let
  username = "ben";
  hostname = "lab";
  addr = "${username}@${hostname}";
  system = "aarch64-linux";
  systemStateVersion = "25.05";
in {
  flake.nixosConfigurations.${hostname} = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit hostname username; };
    modules = [
      ({ pkgs, lib, ... }: {
        nixpkgs.hostPlatform.system = system;
        system.stateVersion = systemStateVersion;

        imports = [
          inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
          inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.bluetooth
        ];

        networking.useNetworkd = true;

        services.tailscale.enable = true;

        services.gitea = {
          enable = true;
          database.type = "sqlite3";
          settings.service = {
            DISABLE_REGISTRATION = true;
            REQUIRE_SIGNIN_VIEW = true;
          };
        };

        services.openssh = {
          enable = true;
          settings = {
            PermitRootLogin = "no";
            PasswordAuthentication = true;
          };
        };

        networking.firewall = {
          allowedTCPPorts = [ 22 3000 ];
          allowedUDPPorts = [ 41641 ];
        };

        users.users.${username} = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
        };

        nix.settings = {
          experimental-features = [ "nix-command" "flakes" ];
          trusted-users = [ username ];
        };

        security.sudo.wheelNeedsPassword = false;

        time.timeZone = "Europe/London";
        i18n.defaultLocale = "en_GB.UTF-8";
      })
    ];
  };

  flake.homeConfigurations."${addr}" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.${system};

    extraSpecialArgs = {
      inherit username hostname;
      inputs = builtins.removeAttrs inputs [ "self" ];
    };

    modules = [
      ({ pkgs, ... }: {
        home.stateVersion = "25.05";
        programs.home-manager.enable = true;
        home.username = username;
        home.homeDirectory = "/home/${username}";

        home.packages = with pkgs; [
          git
          tmux
          neovim
        ];
      })
    ];
  };
}
