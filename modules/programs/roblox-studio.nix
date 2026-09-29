{ flake.modules.nixos.robloxStudio = { ... }:
  {
    services.flatpak.enable = true;
  };
}
