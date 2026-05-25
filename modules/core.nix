{
  # NIX OS
  flake.modules.nixos.core = { pkgs, username, hostname, ... }: {

    users.users.${username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ username ];
    };

    nixpkgs.config.allowUnfree = true;

    # Audio (PipeWire)
    security.rtkit.enable = true;

    # SERVICES 
    services = {

      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      xserver = {
        enable = true;
        displayManager.lightdm.enable = true;
        libinput.enable = true;
        xkb = {
          layout = "gb";
          options = "altwin:super_win";
        };
      };

      openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = true; # Temporary for recovery
          KbdInteractiveAuthentication = false;
          MaxAuthTries = 6;
        };
      };
    };

    time.timeZone = "Europe/London";
    i18n.defaultLocale = "en_GB.UTF-8";

    networking.hostName = hostname;
    networking.networkmanager.enable = true;
    networking.firewall.allowedTCPPorts = [ 53317 ];
    networking.firewall.allowedUDPPorts = [ 53317 ];

    security.sudo.wheelNeedsPassword = false;

    fonts.packages = with pkgs; [
      nerd-fonts.hurmit
    ];

  };

  # HOME - MANAGER
  flake.modules.homeManager.core = { pkgs, config, ... }: {

    home.stateVersion = "25.11";
    programs.home-manager.enable = true;
    nixpkgs.config.allowUnfree = true;

    home.packages = with pkgs; [
      curl
      ripgrep
      unzip
      uv
      wget
      nodejs
      live-server
      localsend
      fzf
      coreutils
      bash
      opencode
      git
      tmux
      neovim
      android-tools
      clinfo
      ffmpeg
      nixpkgs-fmt
      (python3.withPackages (ps: with ps; [ black jupytext ]))
    ];

    home.file = {
      ".bashrc".text = builtins.readFile ./programs/config/bash/.bashrc;
      ".tmux.conf".text = builtins.readFile ./programs/config/tmux/tmux.conf;
      ".gitconfig".source = ./programs/config/git/.gitconfig;
      ".config/nvim".source = ./programs/config/nvim;
      ".opencode/AGENTS.md".source = ./programs/config/opencode/AGENTS.md;
      ".opencode/skills".source = ./programs/config/opencode/skills;
    };

    home.sessionVariables = {
      EDITOR = "nvim";
      OPENCODE_CONFIG_DIR = "$HOME/.opencode";
    };

    services.ssh-agent.enable = true;
  };
}
