{ flake.modules.homeManager.davinciResolve = { pkgs, ... }:
  let
    # Blackmagic changed the archive without changing its version or URL.
    davinci-resolve = pkgs.callPackage (
      pkgs.writeText "davinci-resolve.nix" (
        builtins.replaceStrings
          [ "sha256-bQ4Yag4xfIF9Fs0UVKaYFhObMsAof5n+Sy4osw35a9g=" ]
          [ "sha256-+3SB32EHpH9/0hM3h8CrO6f7V4ZAmxUFh3P8m6QDeO0=" ]
          (builtins.readFile "${pkgs.path}/pkgs/by-name/da/davinci-resolve/package.nix")
      )
    ) { };
  in {
    home.packages = [ davinci-resolve ];
  };
}
