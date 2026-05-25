{ flake.modules.homeManager.davinciResolve = { pkgs, ... }: {
  home.packages = with pkgs; [ davinci-resolve ];
}; }
