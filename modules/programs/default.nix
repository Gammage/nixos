{ flake.modules.nixos.programs = { pkgs, ... }: {

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    arandr
    curl
    git
    google-chrome
    home-manager
    live-server
    localsend
    nodejs
    ripgrep
    spotify
    unzip
    uv
    wget

    (python3.withPackages (ps: with ps; [
      black
      jupytext
    ]) )
  ];


}; }
