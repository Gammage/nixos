{ flake.modules.homeManager.obsStudio = { pkgs, ... }:
  {
    home.packages = [
      (pkgs.wrapOBS {
        plugins = [
          pkgs.obs-studio-plugins.obs-aitum-multistream
          pkgs.obs-studio-plugins.obs-vertical-canvas
          pkgs.obs-studio-plugins.droidcam-obs
        ];
      })
    ];
  };
}
