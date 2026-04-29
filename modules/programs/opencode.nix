{ ... }: {
  home.file.".opencode".source = ./opencode-config;

  environment.sessionVariables = {
    OPENCODE_CONFIG_DIR = "$HOME/.opencode";
  };
}
