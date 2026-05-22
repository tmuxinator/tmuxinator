#!/bin/bash


  # Clear rbenv variables before starting tmux
  unset RBENV_VERSION
  unset RBENV_DIR

  tmux -L interface start-server;

cd /workspace/array-panes

# Run on_project_start command.



  # Run pre command.
  

  # Run on_project_first_start command.
  

  tmux -L interface new-session -d -s array-panes -n shell



  # Create windows.
  tmux -L interface new-window -c /workspace/array-panes -k -t array-panes:0 -n shell


  # Window "shell"


  
  tmux -L interface send-keys -t array-panes:0.0 bundle\ exec\ rails\ console --sandbox C-m

  tmux -L interface select-layout -t array-panes:0 tiled

  tmux -L interface select-layout -t array-panes:0 
  tmux -L interface select-pane -t array-panes:0.0


  tmux -L interface select-window -t array-panes:0
  tmux -L interface select-pane -t array-panes:0.0

  if [ -z "$TMUX" ]; then
    tmux -L interface -u attach-session -t array-panes
  else
    tmux -L interface -u switch-client -t array-panes
  fi



# Run on_project_exit command.
