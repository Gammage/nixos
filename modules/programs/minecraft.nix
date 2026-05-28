{ flake.modules.homeManager.minecraft = { pkgs, ... }: {
  home.packages = with pkgs; [ minecraft ];
}; }
