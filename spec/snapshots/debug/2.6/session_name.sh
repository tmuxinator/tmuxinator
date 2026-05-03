#!/bin/bash


  # Clear rbenv variables before starting tmux
  unset RBENV_VERSION
  unset RBENV_DIR

  tmux start-server;

cd .

# Run on_project_start command.



  # Run pre command.
  

  # Run on_project_first_start command.
  

  tmux new-session -d -s home_arpa_lab -n main



  # Create windows.
  tmux new-window  -k -t home_arpa_lab:0 -n main


  # Window "main"


  
  tmux send-keys -t home_arpa_lab:0.0 echo\ ok C-m

  tmux select-layout -t home_arpa_lab:0 tiled

  tmux select-layout -t home_arpa_lab:0 
  tmux select-pane -t home_arpa_lab:0.0


  tmux select-window -t home_arpa_lab:0
  tmux select-pane -t home_arpa_lab:0.0

  if [ -z "$TMUX" ]; then
    tmux -u attach-session -t home_arpa_lab
  else
    tmux -u switch-client -t home_arpa_lab
  fi



# Run on_project_exit command.
