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
          xorg.xinit
        ];
      })

      ({ lib, ... }: {
        services.xserver.enable = true;
        services.xserver.displayManager.lightdm.enable = lib.mkForce false;
        services.getty.autologinUser = "ben";
      })

      ({ pkgs, ... }: {
        services.xserver.windowManager.i3 = {
          enable = true;
          config = {
            modifier = "Mod1";
            terminal = "wezterm";
            keybindings = {
              "Mod1+d" = "exec dmenu_run";
              "Mod1+Return" = "exec wezterm";
              "Mod1+Shift+q" = "kill";
              "Mod1+Shift+e" = "exec i3-msg exit";
            };
            bars = [{
              statusCommand = "${pkgs.i3status}/bin/i3status";
            }];
          };
        };
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

      ({ pkgs, ... }: {
        home.username = username;
        home.homeDirectory = "/home/${username}";
        home.packages = [
          pkgs.nerd-fonts.hurmit
        ];
        home.stateVersion = "24.11";
      })

      ({ pkgs, ... }: {
        home.file.".bash_profile".text = ''
          if [ "$(tty)" = "/dev/tty1" ]; then
            exec startx
          fi
        '';
        home.file.".xinitrc".text = ''
          exec i3
        '';
      })

       tmux
       neovim
       bash
       wezterm
       opencode
       git

     ];
  };

}
