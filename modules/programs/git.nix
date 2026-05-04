{ flake.modules.homeManager.git = { ... }: {

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "ben";
        email = "30186471+Gammage@users.noreply.github.com";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

}; }
