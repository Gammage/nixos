{ flake.modules.homeManager.opencode = { pkgs, ... }: {
  home.file.".opencode".source = ./opencode-config;

  home.sessionVariables = {
    OPENCODE_CONFIG_DIR = "$HOME/.opencode";
  };

  home.packages = with pkgs; [
    opencode
  ];
}; }
