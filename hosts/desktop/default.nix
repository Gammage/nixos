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
      localsend
      discord

      ({ pkgs, ...}: {
       environment.systemPackages = with pkgs; [
          steam
          gimp
          davinci-resolve
          clinfo
          ffmpeg
          android-tools
        ];
        boot.loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
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
         services.xserver.displayManager.lightdm.autoLogin.enable = true;
         services.xserver.displayManager.lightdm.autoLogin.user = "ben";
          services.xserver.displayManager.defaultSession = "none+i3";
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

      ({ pkgs, ...}: {
        home.username = username;
        home.homeDirectory = "/home/${username}";
        home.packages = [
          pkgs.nerd-fonts.hurmit
          pkgs.quarto
        ];
        home.sessionVariables = {
          LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.zlib}/lib";
        };
        home.stateVersion = "24.11";
      })
      tmux
      neovim
      moltenPython
      bash
      wezterm
      opencode
      git
      i3
      chrome
    ];
  };
}
