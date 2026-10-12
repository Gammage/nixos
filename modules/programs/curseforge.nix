{ flake.modules.homeManager.curseforge = { pkgs, ... }: {
  home.packages = with pkgs; [ wowup-cf ];
}; }
