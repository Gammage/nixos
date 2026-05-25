{ self, inputs, pkgs, ... }:
let
  username = "ben";
  hostname = "laptop";
  addr = "${username}@${hostname}";
  system = "x86_64-linux";
  systemStateVersion = "25.11";
in {
  flake.nixosConfigurations.${hostname} = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit hostname username; };
    modules = with self.modules.nixos; [
      core

      ({ lib, ... }: {
        services.xserver.windowManager.i3.enable = true;
        services.xserver.displayManager.defaultSession = "none+i3";
      })

      {
        boot.loader = {
  	  systemd-boot.enable = true;
  	  efi.canTouchEfiVariables = true;
	};
      
        nixpkgs.hostPlatform.system = system;
        system.stateVersion = systemStateVersion;
        
     # Bluetooth
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
 
      }

	./_nix/hardware-configuration.nix
    ];
  };

  flake.homeConfigurations."${addr}"= inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.${system};

    extraSpecialArgs = {
      inherit username hostname;
      # strip out `self` to avoid infinite recursion
      inputs = builtins.removeAttrs inputs [ "self" ];
    };

    modules = with self.modules.homeManager; [
      core
      graphical

      {
        home.username = username;
        home.file.".config/i3".source = ../../modules/programs/config/i3/laptop;
        home.homeDirectory = "/home/${username}";
      }
    ];
  };
}
