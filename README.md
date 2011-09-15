# Tmuxinator

Create and manage tmux sessions easily. Inspired by Jon Druse's ([Screeninator](https://github.com/jondruse/screeninator)) and Arthur Chiu's ([Terminitor](http://github.com/achiu/terminitor))

## Example

![Sample](http://f.cl.ly/items/3e3I1l1t3D2U472n1h0h/Screen%20shot%202010-12-10%20at%2010.59.17%20PM.png)


## Installation

    $ gem install tmuxinator

## Editor and Shell

tmuxinator uses your shell's default editor for opening files.  If you're not sure what that is type:

    $ echo $EDITOR

For me that produces "mate -w"
If you want to change your default editor simple put a line in ~/.bashrc that changes it. Mine looks like this:

    export EDITOR='mate -w'

## Environment Integration

Add this to your ~/.bashrc (or similar)

[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator

## Usage


### Create a project ###

    $ tmuxinator new project_name

Create or edit your projects with this command, for editing you can also use `tmuxinator open project_name`. `new` aliased to `o`,`open` and `n`. Your default editor ($EDITOR) is used to open the file. If this is a new project you will see this default config:

    # ~/.tmuxinator/project_name.yml
    # you can make as many tabs as you wish...

    project_name: Tmuxinator
    project_root: ~/code/rails_project
    rvm: 1.9.2@rails_project
    pre: sudo /etc/rc.d/mysqld start
    tabs:
      - editor:
          layout: main-vertical
          panes:
            - vim
            - #empty, will just run plain bash
            - top
      - shell: git pull
      - database: rails db
      - server: rails s
      - logs: tail -f logs/development.log
      - console: rails c
      - capistrano:
      - server: ssh me@myhost


If a tab contains multiple commands, they will be 'joined' together with '&&'.
If you want to have your own default config, place it into $HOME/.tmuxinator/default.yml

The `pre` command allows you to run anything before starting the tmux session. Could be handy to make sure you database daemons are running. Multiple commands can be specified, just like for tabs.

## Panes Support
you can define your own panes inside a window likes this:

    - window_with_panes
        layout: main-vertical
        panes:
          - vim
          - #empty, will just run plain bash
          - top


## Starting a project

    $ start_[project_name]

## Shorthand

You can also use this shorthand alias for tmuxinator 

    $ mux [command/project_name]

This will fire up tmux with all the tabs you configured.

## Other Commands

    $ tmuxinator copy existing_project new_project

Copy an existing project. aliased to `c`


    $ tmuxinator list

List all the projects you have configured. aliased to `l`


    $ tmuxinator delete project_name

Remove a project


    $ tmuxinator implode

Remove all tmuxinator configs, aliases and scripts. aliased to `i`

	$ tmuxinator doctor

Examines your environment and identifies problems with your configuration


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
* [Ian Yang](https://github.com/doitian)
* [Bjørn Arild Mæland](https://github.com/bmaland)
* [Dane O'Connor](https://github.com/thedeeno)
* [Eric Marden](https://github.com/xentek)


## History
###v. 0.4.0
* Does not crash if given an invalid yaml file format. report it and exit gracefully.
* Removed clunky scripts & shell aliases (Thanks to Dane O'Connor)
* Config files are now rendered JIT (Thanks to Dane O'Connor)
* Can now start sessions from cli (Thanks to Dane O'Connor)

###v. 0.3.0
* Added pre command (Thanks to Ian Yang)
* Added multiple pre command (Thanks to Bjørn Arild Mæland)
* Using tmux set default-path for project root
* New aliases

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
