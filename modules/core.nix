{
  # NIX OS
  flake.modules.nixos.core = { pkgs, lib, username, hostname, ... }: {

    users.users.${username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ username ];
    };

    nixpkgs.config.allowUnfree = true;

    # SERVICES 
    services = {
      openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = true; # Temporary for recovery
          KbdInteractiveAuthentication = false;
          MaxAuthTries = 6;
        };
      };

      tailscale.enable = true;
    };

    time.timeZone = "Europe/London";
    i18n.defaultLocale = "en_GB.UTF-8";

    networking.hostName = hostname;
    networking.networkmanager.enable = lib.mkDefault true;

    security.sudo.wheelNeedsPassword = false;

  };

  # HOME - MANAGER
  flake.modules.homeManager.core = { pkgs, config, inputs, ... }: {

    home.stateVersion = "25.11";
    programs.home-manager.enable = true;
    nixpkgs.config.allowUnfree = true;

    home.packages = with pkgs; [
      curl
      ripgrep
      unzip
      wget
      nodejs
      live-server
      fzf
      coreutils
      bash
      inputs.opencode.packages.${pkgs.system}.opencode
      git
      gh
      tmux
      neovim
      devenv
      android-tools
      clinfo
      ffmpeg
      nixpkgs-fmt
      yazi
      yt-dlp
      (python3.withPackages (ps: with ps; [ black jupytext ]))
    ];

    home.file = {
      ".bashrc".text = builtins.readFile ./programs/config/bash/.bashrc;
      ".bash_profile".text = "if [ -f \"$HOME/.bashrc\" ]; then source \"$HOME/.bashrc\"; fi";
      ".tmux.conf".text = builtins.readFile ./programs/config/tmux/tmux.conf;
      ".gitconfig".source = ./programs/config/git/.gitconfig;
      ".config/nvim".source = ./programs/config/nvim;
      # opencode only reads global rules from ~/.config/opencode/AGENTS.md.
      # ~/.opencode/AGENTS.md is NOT loaded, despite OPENCODE_CONFIG_DIR pointing
      # there. Verified empirically with a canary file: the ~/.config path loads,
      # the ~/.opencode path does not. Do not add instructions to that path.
      ".config/opencode/AGENTS.md".source = ./programs/config/opencode/AGENTS.md;
      ".opencode/skills".source = ./programs/config/opencode/skills;
      ".opencode/scripts".source = ./programs/config/opencode/scripts;
      ".config/opencode/opencode.json".source = ./programs/config/opencode/opencode.json;
    };

    home.sessionVariables = {
      EDITOR = "nvim";
      OPENCODE_CONFIG_DIR = "$HOME/.opencode";
    };

    services.ssh-agent.enable = true;
  };
}
