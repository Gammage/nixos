{ flake.modules.homeManager.bash = { pkgs, ... }: {
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      # Auto authenticate key

      alias obsidian='(nohup obsidian >/dev/null 2>&1 &)'

      # Activate/deactivate venv
      alias venv='if [[ -n $VIRTUAL_ENV_PROMPT ]]; then deactivate; elif [ -d "./.venv" ]; then source ./.venv/bin/activate; elif [ -d "./venv" ]; then source ./venv/bin/activate; else echo "no environment found"; fi'

      # history & shell behaviour
      HISTCONTROL=ignoreboth
      shopt -s histappend
      HISTSIZE=1000
      HISTFILESIZE=2000
      shopt -s checkwinsize

      # less
      eval "$(SHELL=/bin/sh lesspipe)"

      # detect color support
      if tput setaf 1 &>/dev/null; then
          color_prompt=yes
      else
          color_prompt=
      fi

      # set fancy prompt
      if [ "$color_prompt" = yes ]; then
          PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
      else
          PS1='\u@\h:\w\$ '
      fi

      # ---- ls colors ----
      test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
      alias ls='ls --color=auto'
      alias grep='grep --color=auto'
      alias fgrep='fgrep --color=auto'
      alias egrep='egrep --color=auto'

      # Make symlinks bright yellow (colorblind-friendly)
      export LS_COLORS="$LS_COLORS:ln=01;93"

      # aliases
      alias ll='ls -alF --color=auto'
      alias la='ls -A --color=auto'
      alias l='ls -CF --color=auto'
    '';
  };

  programs.fzf.enable = true;

  services.ssh-agent.enable = true;

  home.packages = with pkgs; [
    nodejs
  ];
  };
}
