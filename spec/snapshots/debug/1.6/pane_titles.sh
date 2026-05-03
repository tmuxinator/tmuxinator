#!/bin/bash


  # Clear rbenv variables before starting tmux
  unset RBENV_VERSION
  unset RBENV_DIR

  tmux -L interface start-server;

cd /workspace/pane-titles

# Run on_project_start command.



  # Run pre command.
  

  # Run on_project_first_start command.
  

  tmux -L interface new-session -d -s pane-titles -n editor

  # Set the default path for versions prior to 1.7
  tmux -L interface set-option -t pane-titles default-path /workspace/pane-titles 1>/dev/null

  printf "\033[1;33mWARNING: You have enabled pane titles in your configuration, but the feature is not supported by your version of tmux.
Please consider upgrading to a version that supports it (tmux >=2.6).
\033[0m"

  # Create windows.
  tmux -L interface new-window default-path /workspace/pane-titles -k -t pane-titles:0 -n editor


  # Window "editor"


  tmux -L interface send-keys -t pane-titles:0.0 bundle\ exec\ vim C-m

  tmux -L interface splitw default-path /workspace/pane-titles -t pane-titles:0
  tmux -L interface select-layout -t pane-titles:0 tiled
  tmux -L interface send-keys -t pane-titles:0.1 tail\ -f\ log/test.log C-m

  tmux -L interface select-layout -t pane-titles:0 tiled

  tmux -L interface select-layout -t pane-titles:0 
  tmux -L interface select-pane -t pane-titles:0.0


  tmux -L interface select-window -t pane-titles:0
  tmux -L interface select-pane -t pane-titles:0.0

  if [ -z "$TMUX" ]; then
    tmux -L interface -u attach-session -t pane-titles
  else
    tmux -L interface -u switch-client -t pane-titles
  fi



# Run on_project_exit command.
