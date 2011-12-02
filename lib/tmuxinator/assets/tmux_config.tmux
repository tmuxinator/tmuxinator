#!<%= ENV['SHELL'] || '/bin/bash' %>
tmux <%= socket %> start-server

if ! $(tmux <%= socket %> has-session -t <%=s @project_name %>); then
cd <%= @project_root || "." %>
<%= @pre.kind_of?(Array) ? @pre.join(" && ") : @pre %>
env TMUX= tmux <%= socket %> start-server \; set-option -g base-index 1 \; new-session -d -s <%=s @project_name %> -n <%=s @tabs[0].name %>

# set up tabs and panes
tmux <%= socket %> set-option -t <%=s @project_name %> default-path <%= @project_root %>

# Set up server options
<% unless @global_session_options.nil? %>
<%   @server_options.each do |k, v| %>
<%=    set_server_option(k, v) %>
<%   end %>
<% end %>

# Set up global session options
<% unless @global_session_options.nil? %>
<%   @global_session_options.each do |k, v| %>
<%=    set_global_session_option(k, v) %>
<%   end %>
<% end %>

# Set up global window options
<% unless @global_window_options.nil? %>
<%   @global_window_options.each do |k, v| %>
<%=    set_global_window_option(k, v) %>
<%   end %>
<% end %>

# Set up session options
<% unless @session_options.nil? %>
<%   @session_options.each do |k, v| %>
#   session "<%= k %>"
<%=    set_session_option(k, v) %>
<%   end %>
<% end %>

# Set up window options
<% unless @window_options.nil? %>
<%   @window_options.each do |k, v| %>
#   window "<%= k %>"
<%=    set_window_option(k, v) %>
<%   end %>
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
<%     end %>
tmux <%= socket %> select-layout -t <%= window(i+1) %> <%=s tab.layout %>
<%   end %>
<% end %>

tmux <%= socket %> select-window -t <%= window(1) %>

fi

if [ -z $TMUX ]; then
    tmux <%= socket %> -u attach-session -t <%=s @project_name %>
else
    tmux <%= socket %> -u switch-client -t <%=s @project_name %>
fi
