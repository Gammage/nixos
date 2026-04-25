{ flake.modules.nixos.programs = { pkgs, ... }: {

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [

    git
    curl
    wget
    neovim
    ripgrep
    python3

  ];


}; }
