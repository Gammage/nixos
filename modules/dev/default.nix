{ pkgs }:

let
  mkDataShell = name: extraPkgs: pkgs.mkShell {
    inherit name;
    packages = [
      (pkgs.python3.withPackages (ps: with ps; [
        jupyterlab
        jupytext
        ipykernel
        numpy
        pandas
        matplotlib
      ]))
    ] ++ extraPkgs;
    shellHook = ''
      echo "${name} ready — run 'jupyter lab'";
    '';
  };
in {
  jupyter = mkDataShell "jupyter" [];
}
