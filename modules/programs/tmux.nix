{ flake.modules.homeManager.tmux = { ... }: {

  programs.tmux = {
    enable = true;
    extraConfig = ''
      # remap prefic to C-space
      unbind C-b
      set -g prefix C-space
      bind-key C-space send-prefix

      # alt-z to fullscreen pane
      bind-key -n M-z resize-pane -Z

      # quick config reload
      bind-key r source-file ~/.tmux.conf

      # vi-like navigation
      set-window-option -g mode-keys vi

      # vim-like copy & paste in scroll mode
      bind-key P paste-buffer
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection

      # split panes with | & -
      unbind '"'
      unbind %
      bind-key | split-window -h -c "#{pane_current_path}"
      bind-key - split-window -v -c "#{pane_current_path}"
    '';
  };

}; }
