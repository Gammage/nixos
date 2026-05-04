{ flake.modules.homeManager.xfce = { pkgs, ... }: {

  home.packages = with pkgs; [
    arc-theme
    papirus-icon-theme
  ];

}; }
