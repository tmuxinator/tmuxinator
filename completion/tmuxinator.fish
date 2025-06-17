function __fish_tmuxinator_using_command
    set cmd (commandline -opc)
    if [ (count $cmd) -gt 1 ]
        if [ $argv[1] = $cmd[2] ]
            return 0
        end
    end
    return 1
end

complete --no-files --command tmuxinator --condition __fish_use_subcommand --exclusive --argument "(tmuxinator commands)"
complete --no-files --command tmuxinator --condition '__fish_tmuxinator_using_command start' --argument "(tmuxinator completions start)"
complete --no-files --command tmuxinator --condition '__fish_tmuxinator_using_command open' --argument "(tmuxinator completions open)"
complete --no-files --command tmuxinator --condition '__fish_tmuxinator_using_command edit' --argument "(tmuxinator completions open)"
complete --no-files --command tmuxinator --condition '__fish_tmuxinator_using_command copy' --argument "(tmuxinator completions copy)"
complete --no-files --command tmuxinator --condition '__fish_tmuxinator_using_command delete' --argument "(tmuxinator completions delete)"
complete --no-files --command tmuxinator --condition '__fish_tmuxinator_using_command debug' --argument "(tmuxinator completions start)"
