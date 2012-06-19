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

# Removing the following code to create all windows in one pass:
# <% @tabs[1..-1].each_with_index do |tab, i| %>
# tmux <%= socket %> new-window -t <%= window(i+2) %> -n <%=s tab.name %>
# <% end %>

# Set up tabs and pans -- version 2:
# In this version, "tmux new-window" and tmux splitw" are passed the 
# window/pane command, respectively, as an argument, for example:
#
#      tmux splitw -t 1 "git log"
#
# The only downside is that "tmux send-keys" (and the "pre" field
# for the window/pane) are no longer be used. But this is a small issue with 
# straightforward workarounds.
# 
# In this proposed implementation, exiting or stopping the window/pane command 
# either kills the window/pane or places it in "dead" mode, depending on 
# the remain-on-exit [off | on] session setting. Dead windows/panes can be then
# killed or respawned with a single command or key-binding:
#
# 		tmux respawn-window -t 1
#
# This effectively enables the user to create command-specific views that can be
# easily refreshed with one keystroke and remain neat by making it impossible to
# exit to the shell prompt.

<% @tabs.each_with_index do |tab, i| %>
	<% if tab.command %>
		tmux <%= socket %> new-window -t <%= window(i+1) %> -n <%=s tab.name %> <%=s tab.command %>
	<% elsif tab.panes %>
		tmux <%= socket %> new-window -t <%= window(i+1) %> -n <%=s tab.name %> <%=s tab.panes.shift %>
		<% tab.panes.each do |pane| %>
			tmux <%= socket %> splitw -t <%= window(i+1) %> <%=s pane %>
		<% end%>
		tmux <%= socket %> select-layout -t <%= window(i+1) %> <%=s tab.layout %>
	<% end%>
<% end%>	

# The above code effectively replaces the following:
# # set up tabs and panes
# <% @tabs.each_with_index do |tab, i| %>
# # tab "<%= tab.name %>"
# <%   if tab.command %>
# <%=    send_keys(tab.command, i+1) %>
# <%   elsif tab.panes %>
# <%=    send_keys(tab.panes.shift, i+1) %>
# <%     tab.panes.each do |pane| %>
# tmux <%= socket %> splitw -t <%= window(i+1) %>
# <%=      send_keys(tab.pre, i+1) if tab.pre %>
# <%=      send_keys(pane, i+1) %>
# <%     end %>
# tmux <%= socket %> select-layout -t <%= window(i+1) %> <%=s tab.layout %>
# <%   end %>
# <% end %>

tmux <%= socket %> select-window -t <%= window(1) %>

fi

if [ -z $TMUX ]; then
    tmux <%= socket %> -u attach-session -t <%=s @project_name %>
else
    tmux <%= socket %> -u switch-client -t <%=s @project_name %>
fi
