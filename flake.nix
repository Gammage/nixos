{
  description = "A basic dendritic nix setup";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      inputs.flake-parts.flakeModules.modules
      inputs.home-manager.flakeModules.home-manager
      (inputs.import-tree ./hosts)
      (inputs.import-tree ./modules)
    ];
    systems = [ "x86_64-linux" "aarch64-linux" ];

  };
}
