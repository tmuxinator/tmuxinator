def tmux_list_sessions
  `tmux list-sessions`.split("\n")
end

def tmux_list_windows(name)
  `tmux list-windows -t #{name}`.split("\n")
end
