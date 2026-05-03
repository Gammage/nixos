{ self, inputs, ... }:
let
  username = "ben";
  hostname = "desktop";
  addr = "${username}@${hostname}";
  system = "x86_64-linux";
  systemStateVersion = "25.11";
in {
  flake.nixosConfigurations.${hostname} = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit hostname username; };
    modules = with self.modules.nixos; [
      core
      openssh
      users
      programs
      discord
      
      {
        boot.loader = {
	  systemd-boot.enable = true;
	  efi.canTouchEfiVariables = true;
	};
      
        nixpkgs.hostPlatform.system = system;
        system.stateVersion = systemStateVersion;
        
        hardware.graphics = {
          enable = true;
          enable32Bit = true;
        };
      }
      
      ({ pkgs, ... }: {
        environment.systemPackages = with pkgs; [
          steam
        ];
      }),

	./_nix/hardware-configuration.nix	
    ];
  };

  flake.homeConfigurations."${addr}"= inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.${system};

    extraSpecialArgs = {
      inherit username hostname;
      inputs = builtins.removeAttrs inputs [ "self" ];
    };

    modules = with self.modules.homeManager; [

      {
        home.username = username;
        home.homeDirectory = "/home/${username}";
        home.packages = [
        ];
        home.stateVersion = "24.11";
      }

      tmux
      neovim
      bash
      wezterm
      opencode

    ];
  };

}
