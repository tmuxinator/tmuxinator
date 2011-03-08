# Tmuxinator

Create and manage tmux sessions easily. Inspired by Jon Druse's ([Screeninator](https://github.com/jondruse/screeninator)) and Arthur Chiu's ([Terminitor](http://github.com/achiu/terminitor))

## Example

![Sample](http://f.cl.ly/items/3e3I1l1t3D2U472n1h0h/Screen%20shot%202010-12-10%20at%2010.59.17%20PM.png)


## Installation

    $ gem install tmuxinator

Then follow the instructions.  You just have to drop a line in your ~/.bashrc file, similar to RVM if you've used that before:

    [[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator

## Editor and Shell

tmuxinator uses your shell's default editor for opening files.  If you're not sure what that is type:

    $ echo $EDITOR

For me that produces "mate -w"
If you want to change your default editor simple put a line in ~/.bashrc that changes it. Mine looks like this:

    export EDITOR='mate -w'

It also uses $SHELL variable. which is always set by your shell.

## Usage


### Create a project ###

    $ tmuxinator open project_name

Create or edit your projects with this command. aliased to `o`. Your default editor ($EDITOR) is used to open the file. If this is a new project you will see this default config:

    # ~/.tmuxinator/project_name.yml
    # you can make as many tabs as you wish...

    project_name: tmuxinator
    project_root: ~/code/rails_project
    rvm: 1.9.2@rails_project
    tabs:
      - shell: git pull
      - database: rails db
      - console: rails c
      - logs:
        - cd logs
        - tail -f development.log
      - ssh: ssh me@myhost
      - window_with_panes
          layout: main-vertical
          panes:
            - vim
            - #empty, will just run plain bash
            - top

If a tab contains multiple commands, they will be 'joined' together with '&&'.
If you want to have your own default config, place it into $HOME/.tmuxinator/default.yml

## Panes Support
you can define your own panes inside a window likes this:

    - window_with_panes
        layout: main-vertical
        panes:
          - vim
          - #empty, will just run plain bash
          - top


## Starting a project

    $ start_project_name

This will fire up tmux with all the tabs you configured.

### Limitations ###

After you create a project, you will have to open a new shell window. This is because tmuxinator adds an
alias to bash (or any other shell you use, like zsh) to open tmux with the project config. You can reload your shell rc file
instead of openning a new window like this, for instance in bash you could do this:

    $ source ~/.bashrc

## Other Commands

    $ tmuxinator copy existing_project new_project

Copy an existing project. aliased to `c`


    $ tmuxinator update_scripts

Re-create the tmux scripts and aliases from the configs. Use this only if you edit your project configs outside of tmuxinator, i.e. not using "tmuxinator open xxx".


    $ tmuxinator list

List all the projects you have configured. aliased to `l`


    $ tmuxinator delete project_name

Remove a project


    $ tmuxinator implode

Remove all tmuxinator configs, aliases and scripts. aliased to `i`


    $ tmuxinator version

shows tmuxinator's version. aliased to `v`


    $ tmuxinator help

shows tmuxinator's help. aliased to `h`

## Questions? Comments? Feature Request?

I would love to hear your feedback on this project!  Send me a message!

## Contributors:

* [Aaron Spiegel](https://github.com/spiegela)
* [Jay Adkisson](https://github.com/jayferd)
* [Chris Lerum](https://github.com/chrislerum)
* [David Bolton](https://github.com/lightningdb)
* [Thibault Duplessis](https://github.com/ornicar)

## History
###v. 0.2.0
* added pane support (Thanks to Aaron Spiegel)
* RVM support (Thanks to Jay Adkisoon)

## Contributing to tmuxinator

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2010 Allen Bargi. See LICENSE.txt for further details.
