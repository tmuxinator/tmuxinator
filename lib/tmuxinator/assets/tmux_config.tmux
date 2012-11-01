#!<%= ENV['SHELL'] || '/bin/bash' %>
tmux <%= socket %> start-server

if ! $(tmux <%= socket %> has-session -t <%=s @project_name %>); then
cd <%= @project_root || "." %>
<%= @pre.kind_of?(Array) ? @pre.join(" && ") : @pre %>
env TMUX= tmux <%= socket %> start-server \; new-session -d -s <%=s @project_name %> -n <%=s @tabs[0].name %>
tmux <%= socket %> set-option -t <%=s @project_name %> default-path <%= @project_root %>

<% settings.each do |setting| %>
tmux <%= socket %> set-option -t <%=s @project_name%> <%= setting %>
<% end %>

<% hotkeys.each do |hotkey| %>
tmux <%= socket %> bind-key <%= hotkey %>
<% end %>

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

tmux <%= socket %> select-window -t <%= window(0) %>

fi

if [ -z $TMUX ]; then
    tmux <%= cli_args %> <%= socket %> -u attach-session -t <%=s @project_name %>
else
    tmux <%= socket %> -u switch-client -t <%=s @project_name %>
fi
