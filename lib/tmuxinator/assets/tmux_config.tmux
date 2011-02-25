#!<%= ENV['SHELL'] || '/bin/bash' %>
cd <%=s @project_root %>
tmux start-server

if ! $(tmux has-session -t <%=s @project_name %>); then

tmux set-option base-index 1
tmux new-session -d -s <%=s @project_name %> -n <%=s @tabs[0].name %>

<% @tabs[1..-1].each_with_index do |tab, i| %>
tmux new-window -t <%= window(i+1) %> -n <%=s tab.name %>
<% end %>

# set up tabs and panes
<% @tabs.each_with_index do |tab, i| %>
# tab "<%= tab.name %>"
<%   if tab.command %>
<%=    send_keys(tab.command, i) %>
<%   elsif tab.panes %>
<%=    send_keys(tab.panes.shift, i) %>
<%     tab.panes.each do |pane| %>
tmux splitw -t <%= window(i) %>
<%=      send_keys(pane, i) %>
<%     end %>
tmux select-layout -t <%= window(i) %> <%=s tab.layout %>
<%   end %>
<% end %>

tmux select-window -t <%= window(1) %>

fi

if [ -z $TMUX ]; then
    tmux -u attach-session -t <%=s @project_name %>
else
    tmux -u switch-client -t <%=s @project_name %>
fi
