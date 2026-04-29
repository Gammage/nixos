{ self, inputs, ... }:
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
      openssh
      users

      {
        boot.loader = {
	  systemd-boot.enable = true;
	  efi.canTouchEfiVariables = true;
	};

        nixpkgs.hostPlatform.system = system;
        system.stateVersion = systemStateVersion;
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

      {

        home.username = username;
        home.homeDirectory = "/home/${username}";
        home.packages = [
          # inputs.nixvim.packages.${system}.default
        ];

        # This value determines the home Manager release that your
        # configuration is compatible with. This helps avoid breakage
        # when a new home Manager release introduces backwards
        # incompatible changes.
        #
        # You can update home Manager without changing this value. See
        # the home Manager release notes for a list of state version
        # changes in each release.
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
