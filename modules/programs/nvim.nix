{ flake.modules.homeManager.neovim = { ... }: {

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  home.file.".config/nvim".source = ./nvim-config;

}; }
