{ flake.modules.homeManager.obsStudio = { pkgs, ... }:
  let
    aitumStreamSuite =
      pkgs.callPackage ../../pkgs/obs-aitum-stream-suite {};
  in {
    home.packages = [
      (pkgs.wrapOBS {
        plugins = [ aitumStreamSuite ];
      })
    ];
  };
}
