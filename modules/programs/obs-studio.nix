{ flake.modules.homeManager.obsStudio = { pkgs, ... }: {
  home.packages = [
    (pkgs.wrapOBS {
      plugins = [
        pkgs.obs-studio-plugins.obs-aitum-multistream
      ];
    })
  ];
}; }
