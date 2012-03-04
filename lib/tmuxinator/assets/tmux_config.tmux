#!<%= ENV['SHELL'] || '/bin/bash' %>
tmux <%= socket %> start-server

if ! $(tmux <%= socket %> has-session -t <%=s @project_name %>); then
cd <%= @project_root || "." %>
<%= @pre.kind_of?(Array) ? @pre.join(" && ") : @pre %>
env TMUX= tmux <%= socket %> start-server \; set-option -g base-index 1 \; new-session -d -s <%=s @project_name %> -n <%=s @tabs[0].name %>
tmux <%= socket %> set-option -t <%=s @project_name %> default-path <%= @project_root %>

<% settings.each do |setting| %>
tmux <%= socket %> set-option -t <%=s @project_name%> <%= setting %>
<% end %>

<% hotkeys.each do |hotkey| %>
tmux <%= socket %> bind-key <%= hotkey %>
<% end %>

<% @tabs[1..-1].each_with_index do |tab, i| %>
tmux <%= socket %> new-window -t <%= window(i+2) %> -n <%=s tab.name %>
<% end %>

# set up tabs and panes
<% @tabs.each_with_index do |tab, i| %>
# tab "<%= tab.name %>"
<%   if tab.command %>
<%=    send_keys(tab.command, i+1) %>
<%   elsif tab.panes %>
<%=    send_keys(tab.panes.shift, i+1) %>
<%     tab.panes.each do |pane| %>
tmux <%= socket %> splitw -t <%= window(i+1) %>
<%=      send_keys(tab.pre, i+1) if tab.pre %>
<%=      send_keys(pane, i+1) %>
tmux <%= socket %> select-layout -t <%= window(i+1) %> <%=s tab.layout %>
<%     end %>
<%   end %>
<% end %>

tmux <%= socket %> select-window -t <%= window(1) %>

fi

if [ -z $TMUX ]; then
    tmux <%= socket %> -u attach-session -t <%=s @project_name %>
else
    tmux <%= socket %> -u switch-client -t <%=s @project_name %>
fi
