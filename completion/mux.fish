function __fish_mux_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

complete -f -c mux -a '(mux completions start)'
complete -f -c mux -a '(mux commands)'
complete -f -c mux -n '__fish_mux_using_command start' -a '(mux completions start)'
complete -f -c mux -n '__fish_mux_using_command open' -a '(mux completions open)'
complete -f -c mux -n '__fish_mux_using_command copy' -a '(mux completions copy)'
complete -f -c mux -n '__fish_mux_using_command delete' -a '(mux completions delete)'
