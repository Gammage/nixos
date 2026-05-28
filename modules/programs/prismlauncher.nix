{ flake.modules.homeManager.prismlauncher = { pkgs, ... }: {
  home.packages = with pkgs; [ prismlauncher ];
}; }
