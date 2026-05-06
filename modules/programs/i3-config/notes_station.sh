#!/bin/bash
# Open WezTerm with tmux in ~/notes, running nvim
wezterm start -- tmux new-session -A -s notes -c "$HOME/notes" "nvim ."
