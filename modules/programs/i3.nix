{ flake.modules.homeManager.i3 = { pkgs, ... }: {
  home.packages = with pkgs; [ dmenu i3 i3status ];
  home.file.".config/i3/config".source = ./i3-config;
}; }
