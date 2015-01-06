function __fish_tmuxinator_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

set __fish_tmuxinator_program_cmd (commandline -o)[1]

function __fish_tmuxinator_program
  eval "$__fish_tmuxinator_program_cmd $argv"
end

complete -f -c $__fish_tmuxinator_program_cmd                                                -a '(__fish_tmuxinator_program completions start)'
complete -f -c $__fish_tmuxinator_program_cmd -n '__fish_use_subcommand'                  -x -a "(__fish_tmuxinator_program commands)"
complete -f -c $__fish_tmuxinator_program_cmd -n '__fish_tmuxinator_using_command start'     -a "(__fish_tmuxinator_program completions start)"
complete -f -c $__fish_tmuxinator_program_cmd -n '__fish_tmuxinator_using_command open'      -a "(__fish_tmuxinator_program completions open)"
complete -f -c $__fish_tmuxinator_program_cmd -n '__fish_tmuxinator_using_command copy'      -a "(__fish_tmuxinator_program completions copy)"
complete -f -c $__fish_tmuxinator_program_cmd -n '__fish_tmuxinator_using_command delete'    -a "(__fish_tmuxinator_program completions delete)"
