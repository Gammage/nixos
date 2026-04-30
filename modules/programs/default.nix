{ flake.modules.nixos.programs = { pkgs, ... }: {

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    ripgrep
    python3
    nodejs
    nodePackages.live-server
    nerdfonts.hermit
    home-manager
  ];


}; }
