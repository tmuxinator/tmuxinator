#!/bin/bash


  # Clear rbenv variables before starting tmux
  unset RBENV_VERSION
  unset RBENV_DIR

  tmux -L interface start-server;

cd /workspace/basic

# Run on_project_start command.



  # Run pre command.
  

  # Run on_project_first_start command.
  

  tmux -L interface new-session -d -s basic -n editor



  # Create windows.
  tmux -L interface new-window -c /workspace/basic/app -k -t basic:0 -n editor
  tmux -L interface new-window -c /workspace/basic -k -t basic:1 -n shell


  # Window "editor"


  
  tmux -L interface send-keys -t basic:0.0 bundle\ exec\ ruby\ -v C-m
  tmux -L interface send-keys -t basic:0.0 bundle\ exec\ vim C-m

  tmux -L interface splitw -c /workspace/basic/app -t basic:0
  tmux -L interface select-layout -t basic:0 tiled
  
  tmux -L interface send-keys -t basic:0.1 bundle\ exec\ ruby\ -v C-m
  tmux -L interface send-keys -t basic:0.1 bundle\ exec\ rake\ test C-m

  tmux -L interface select-layout -t basic:0 tiled

  tmux -L interface select-layout -t basic:0 
  tmux -L interface select-pane -t basic:0.0


  # Window "shell"


  
  tmux -L interface send-keys -t basic:1.0 bundle\ exec\ ruby\ -v C-m
  tmux -L interface send-keys -t basic:1.0 bin/setup C-m

  tmux -L interface select-layout -t basic:1 tiled

  tmux -L interface select-layout -t basic:1 
  tmux -L interface select-pane -t basic:1.0


  tmux -L interface select-window -t basic:0
  tmux -L interface select-pane -t basic:0.0

  if [ -z "$TMUX" ]; then
    tmux -L interface -u attach-session -t basic
  else
    tmux -L interface -u switch-client -t basic
  fi



# Run on_project_exit command.
