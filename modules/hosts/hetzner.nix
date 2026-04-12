{ config, inputs, ... }:
let
  hostname = "yor-zarad";
  username = "n";
  system = "x86_64-linux";
in {
  flake.nixosConfigurations.hetzner = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit hostname username; };
    modules = with config.flake.modules.nixos; [
      inputs.disko.nixosModules.disko
      disko-hetzner
      base
      openssh
      users
      {
        hardware.facter.reportPath = ./facter.json;
        system.stateVersion = "24.11";
      }
    ];
  };
}
