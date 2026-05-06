{ flake.modules.homeManager.i3 = { pkgs, ... }: {
  home.packages = with pkgs; [ dmenu i3 i3status ];
  home.file.".config/i3".source = ./i3-config;

  # Script to open WezTerm with tmux in ~/notes and launch nvim
  home.file.".local/bin/notes_station".source = ./i3-config/notes_station.sh;
}; }
