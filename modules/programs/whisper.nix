{ flake.modules.homeManager.whisper = { pkgs, ... }:
  {
    home.packages = [
      (pkgs.whisper-cpp.override { vulkanSupport = true; withSDL = false; })
    ];
  };
}