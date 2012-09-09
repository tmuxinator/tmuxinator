#!<%= ENV['SHELL'] || '/bin/bash' %>
tmux <%= socket %> start-server

if ! $(tmux <%= socket %> has-session -t <%=s @project_name %>); then
cd <%= @project_root || "." %>
<%= @pre.kind_of?(Array) ? @pre.join(" && ") : @pre %>
env TMUX= tmux <%= socket %> start-server \; new-session -d -s <%=s @project_name %> -n <%=s @tabs[0].name %>
tmux <%= socket %> set-option -t <%=s @project_name %> default-path <%= @project_root %>

<% @tabs[1..-1].each_with_index do |tab, i| %>
tmux <%= socket %> new-window -t <%= window(i+1) %> -n <%=s tab.name %>
<% end %>

# set up tabs and panes
<% @tabs.each_with_index do |tab, i| %>
# tab "<%= tab.name %>"
<%   if tab.command %>
<%=    send_keys(tab.command, i) %>
<%   elsif tab.panes %>
<%=    send_keys(tab.panes.shift, i) %>
<%     tab.panes.each do |pane| %>
tmux <%= socket %> splitw -t <%= window(i) %>
<%=      send_keys(pane, i) %>
<%     end %>
tmux <%= socket %> select-layout -t <%= window(i) %> <%=s tab.layout %>
<%   end %>
<% end %>

tmux <%= socket %> select-window -t <%= window(0) %>

fi

if [ -z $TMUX ]; then
    tmux <%= cli_args %> <%= socket %> -u attach-session -t <%=s @project_name %>
else
    tmux <%= socket %> -u switch-client -t <%=s @project_name %>
fi
