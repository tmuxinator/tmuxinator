tmux set-option -g base-index 1

cd "<%= @project_root %>"

tmux start-server
tmux new-session -d -s <%= @project_name %>

<% @tabs.each do |tab| %>
tmux new-window -t <%= @project_name %>:<%= @tabs.index(tab) + 1 %> -n <%= tab.name %>
tmux send-keys  -t <%= @project_name %>:<%= @tabs.index(tab) + 1 %> 'cd <%= @project_root %> && <%= tab.stuff %>' C-m
<% end %>

tmux select-window -t <%= @project_name %>:0
tmux attach-session -t <%= @project_name %>

