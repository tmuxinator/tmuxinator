cd <%= @project_root %>
tmux start-server

if ! $(tmux has-session -t <%= @project_name %>); then

tmux new-session -d -s <%= @project_name %> -n <%= @tabs[0].name %>
tmux set-option -t <%= @project_name %> base-index 1

<% @tabs.each do |tab| %>
  <% unless @tabs.index(tab) == 0 %>
tmux new-window -t <%= @project_name %>:<%= @tabs.index(tab) + 1 %> -n <%= tab.name %>
  <% end %>
<% end %>

<% @tabs.each do |tab| %>
tmux send-keys  -t <%= @project_name %>:<%= @tabs.index(tab) + 1 %> '<%= tab.stuff %>' C-m
<% end %>

tmux select-window -t <%= @project_name %>:1

fi

tmux -u attach-session -t <%= @project_name %>
