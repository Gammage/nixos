{ flake.modules.homeManager.chrome = { pkgs, ... }: {
  home.packages = with pkgs; [
    (writeShellScriptBin "chrome" ''
      exec ${google-chrome}/bin/google-chrome-stable --new-window "$@"
    '')
  ];
}; }
