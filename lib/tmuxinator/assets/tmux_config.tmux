#!<%= ENV['SHELL'] || '/bin/bash' %>
tmux start-server

if ! $(tmux has-session -t <%=s @project_name %>); then
cd <%= @project_root || "." %>
<%= @pre.kind_of?(Array) ? @pre.join(" && ") : @pre %>
env TMUX= tmux new-session -d -s <%=s @project_name %> -n <%=s @tabs[0].name %>
tmux set default-path <%= @project_root %>
tmux set-option base-index 1

<% @tabs[1..-1].each_with_index do |tab, i| %>
tmux new-window -t <%= window(i+2) %> -n <%=s tab.name %>
<% end %>

# set up tabs and panes
<% @tabs.each_with_index do |tab, i| %>
# tab "<%= tab.name %>"
<%   if tab.command %>
<%=    send_keys(tab.command, i+1) %>
<%   elsif tab.panes %>
<%=    send_keys(tab.panes.shift, i+1) %>
<%     tab.panes.each do |pane| %>
tmux splitw -t <%= window(i+1) %>
<%=      send_keys(pane, i+1) %>
<%     end %>
tmux select-layout -t <%= window(i+1) %> <%=s tab.layout %>
<%   end %>
<% end %>

tmux select-window -t <%= window(1) %>

fi

if [ -z $TMUX ]; then
    tmux -u attach-session -t <%=s @project_name %>
else
    tmux -u switch-client -t <%=s @project_name %>
fi
