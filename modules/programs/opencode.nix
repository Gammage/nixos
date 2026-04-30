{ flake.modules.homeManager.opencode = { ... }: {
  home.file.".opencode".source = ./opencode-config;

  home.sessionVariables = {
    OPENCODE_CONFIG_DIR = "$HOME/.opencode";
  };
}; }
