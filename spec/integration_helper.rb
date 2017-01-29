def tmux_list_sessions
  `tmux list-sessions -F '#S'`.split("\n")
end

def tmux_list_windows(name)
  `tmux list-windows -t #{name} -F '#W'`.split("\n")
end
