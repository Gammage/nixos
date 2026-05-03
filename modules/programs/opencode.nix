{ flake.modules.homeManager.opencode = { pkgs, ... }: {

  home.sessionVariables = {
    OPENCODE_CONFIG_DIR = "$HOME/.opencode";
  };

  home.packages = with pkgs; [
    opencode
  ];

  # Copy config files (excluding node_modules to avoid runtime conflicts)
  home.file.".opencode/AGENTS.md".source = ./opencode-config/AGENTS.md;
  home.file.".opencode/skills".source = ./opencode-config/skills;
}; }
