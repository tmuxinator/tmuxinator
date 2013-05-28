# Tmuxinator [![Build Status](https://secure.travis-ci.org/aziz/tmuxinator.png)](http://travis-ci.org/aziz/tmuxinator?branch=master) [![Coverage Status](https://coveralls.io/repos/aziz/tmuxinator/badge.png)](https://coveralls.io/r/aziz/tmuxinator) [![Code Climate](https://codeclimate.com/github/aziz/tmuxinator.png)](https://codeclimate.com/github/aziz/tmuxinator) [![Dependency Status](https://gemnasium.com/aziz/tmuxinator.png)](https://gemnasium.com/aziz/tmuxinator)

Create and manage tmux sessions easily.

### Example

![Screenshot](http://f.cl.ly/items/3e3I1l1t3D2U472n1h0h/Screen%20shot%202010-12-10%20at%2010.59.17%20PM.png)

## Installation

``` bash
$ gem install tmuxinator
```

## Editor and Shell

tmuxinator uses your shell's default editor for opening files.  If you're not sure what that is type:

``` bash
$ echo $EDITOR
```
For me that produces "mate -w"
If you want to change your default editor simple put a line in ~/.bashrc that changes it. Mine looks like this:

``` bash
export EDITOR='mate -w'
```

## Environment Integration

Add this to your `~/.bashrc` (or similar)

``` bash
[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator
```

For command line completion you can source the `tmuxinator_completion` file, which is in the same directory as
`tmuxinator` binary file. That will auto-complete `tmuxinator` commands, plus your `.yml` config files.

## Usage

### Create a project

``` bash
$ tmuxinator new project_name
```

Create or edit your projects with this command, for editing you can also use `tmuxinator open project_name`. `new` aliased to `o`,`open` and `n`. Your default editor ($EDITOR) is used to open the file. If this is a new project you will see this default config:

``` yaml
# ~/.tmuxinator/project_name.yml
# you can make as many tabs as you wish...

project_name: Tmuxinator
project_root: ~/code/rails_project
socket_name: foo # Not needed. Remove to use default socket
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
```

If a tab contains multiple commands, they will be joined together with `&&`.
If you want to have your own default config, place it into $HOME/.tmuxinator/default.yml

The `pre` command allows you to run anything before starting the tmux session. Could be handy to make sure you database daemons are running. Multiple commands can be specified, just like for tabs.

## Panes Support
You can define your own panes inside a window likes this:

``` yaml
- window_with_panes
    layout: main-vertical
    panes:
      - vim
      - #empty, will just run plain bash
      - top
```

The layout setting gets handed down to tmux directly, so you can choose from one of [the five standard layouts](http://manpages.ubuntu.com/manpages/precise/en/man1/tmux.1.html#contenttoc6) or [specify your own](http://stackoverflow.com/a/9976282/183537).

## Starting a project

``` bash
$ start_[project_name]
```

## Shorthand

You can also use this shorthand alias for tmuxinator

``` bash
$ mux [command/project_name]
```

This will fire up tmux with all the tabs you configured.

## Other Commands

Copy an existing project. aliased to `c` and `cp`
``` bash
$ tmuxinator copy existing_project new_project
```

List all the projects you have configured. aliased to `l`
``` bash
$ tmuxinator list
```

Remove a project. aliased to `rm`
``` bash
$ tmuxinator delete project_name
```

Remove all tmuxinator configs, aliases and scripts. aliased to `i`
``` bash
$ tmuxinator implode
```

Examines your environment and identifies problems with your configuration
``` bash
$ tmuxinator doctor
```

Shows tmuxinator's version. aliased to `v`
``` bash
$ tmuxinator version
```

Shows tmuxinator's help. aliased to `h`
``` bash
$ tmuxinator help
```

## Questions? Comments? Feature Request?

I would love to hear your feedback on this project! head over to [issues](https://github.com/aziz/tmuxinator/issues)
section and make a ticket.

## Contributors

[See the full list of contributors](https://github.com/aziz/tmuxinator/contributors)

## Inspiration and Thanks

Inspired by Jon Druse's ([Screeninator](https://github.com/jondruse/screeninator)) and Arthur Chiu's ([Terminitor](http://github.com/achiu/terminitor))

## Contributing to tmuxinator

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is
  otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2010-2012 Allen Bargi. See LICENSE for further details.
