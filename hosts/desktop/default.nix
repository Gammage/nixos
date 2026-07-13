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
      graphical

      ({ pkgs, ...}: {
        boot.loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };

        boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

        nixpkgs.hostPlatform.system = system;
        system.stateVersion = systemStateVersion;
         
        hardware.graphics = {
           enable = true;
           enable32Bit = true;
           extraPackages = with pkgs; [
             rocmPackages.clr.icd
           ];
         };
       })

       ({ lib, ... }: {
         services.xserver.windowManager.i3.enable = true;
         services.displayManager.autoLogin.enable = true;
         services.displayManager.autoLogin.user = "ben";
         services.displayManager.defaultSession = "none+i3";
       })

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
      core
      graphical
      davinciResolve
      spotify
      steam
      prismlauncher

      ({ pkgs, ...}: {
        home.username = username;
        home.homeDirectory = "/home/${username}";
        home.file.".config/i3".source = ../../modules/programs/config/i3/desktop;
        home.sessionVariables = {
          LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.zlib}/lib";
        };

        home.file.".config/polybar".source = ../../modules/programs/config/polybar/desktop;
      })
    ];
  };
}
