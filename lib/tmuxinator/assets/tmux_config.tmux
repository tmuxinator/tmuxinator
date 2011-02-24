cd <%=s @project_root %>
tmux start-server

if ! $(tmux has-session -t <%=s @project_name %>); then

tmux set-option base-index 1
tmux new-session -d -s <%=s @project_name %> -n <%=s @tabs[0].name %>

<% @tabs.each do |tab| %>
  <% unless @tabs.index(tab) == 0 %>
tmux new-window -t <%=s @project_name %>:<%=s @tabs.index(tab) + 1 %> -n <%=s tab.name %>
  <% end %>
<% end %>

<% @tabs.each do |tab| %>
tmux send-keys  -t <%=s @project_name %>:<%=s @tabs.index(tab) + 1 %> <%=s tab.stuff %> C-m
<% end %>

tmux select-window -t <%=s @project_name %>:1

fi

if [ -z $TMUX ]; then
    tmux -u attach-session -t <%=s @project_name %>
else
    tmux -u switch-client -t <%=s @project_name %>
fi
