# Tmuxinator [![Build Status](https://secure.travis-ci.org/aziz/tmuxinator.png)](http://travis-ci.org/aziz/tmuxinator?branch=master) [![Coverage Status](https://coveralls.io/repos/aziz/tmuxinator/badge.png)](https://coveralls.io/r/aziz/tmuxinator) [![Code Climate](https://codeclimate.com/github/aziz/tmuxinator.png)](https://codeclimate.com/github/aziz/tmuxinator) [![Dependency Status](https://gemnasium.com/aziz/tmuxinator.png)](https://gemnasium.com/aziz/tmuxinator)

Create and manage tmux sessions easily.

### Example

![Screenshot](http://f.cl.ly/items/3e3I1l1t3D2U472n1h0h/Screen%20shot%202010-12-10%20at%2010.59.17%20PM.png)

## Installation

``` bash
$ gem install tmuxinator
```

## Editor and Shell

tmuxinator uses your shell's default editor for opening files.  If you're not
sure what that is type:

``` bash
$ echo $EDITOR
```

For me that produces "vim" If you want to change your default editor simple
put a line in ~/.bashrc that changes it. Mine looks like this:

``` bash
export EDITOR='vim'
```

## Completion

Download the appropriate completion file from the repo.

### bash

Add the following to your `~/.bashrc`:

    source `which tmuxinator.zsh`

### zsh

Add the following to your `~/.zshrc`:

    source `which tmuxinator.zsh`

## Usage

### Create a project

Create or edit your projects with:

``` bash
$ tmuxinator new [project]
```

For editing you can also use `tmuxinator open [project]`. `new` is aliased to
`o`,`open` and `n`. Your default editor (`$EDITOR`) is used to open the file.
If this is a new project you will see this default config:

``` yaml
name: Tmuxinator
root: ~/Code/tmuxinator
socket_name: foo # Remove to use default socket
pre: sudo /etc/rc.d/mysqld start # Runs before everything
pre_window: rbenv shell 2.0.0-p247 # Runs in each tab and pane
tmux_options: -v -2 # Pass arguments to tmux
windows:
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
If you want to have your own default config, place it into
`$HOME/.tmuxinator/default.yml`

The `pre` command allows you to run anything before starting the tmux session.
Could be handy to make sure you database daemons are running. Multiple commands
can be specified, just like for tabs.

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

The layout setting gets handed down to tmux directly, so you can choose from
one of [the five standard
layouts](http://manpages.ubuntu.com/manpages/precise/en/man1/tmux.1.html#contenttoc6)
or [specify your own](http://stackoverflow.com/a/9976282/183537).

## Starting a session

This will fire up tmux with all the tabs and panes you configured.

``` bash
$ tmuinxator start [project]
```

## Shorthand

You can also use this shorthand alias for tmuxinator

``` bash
$ mux [command]
```

## Interpreter Managers & Environment Variables

To use tmuxinator with rbenv, RVM, NVM etc, use the `pre_tab` option.

```
pre_tab: rbenv shell 2.0.0-p247
```

These commands will run before any pane or window.

## Other Commands

Copy an existing project. Aliased to `c` and `cp`
``` bash
$ tmuxinator copy [existing] [new]
```

List all the projects you have configured. Aliased to `l` and `ls`

``` bash
$ tmuxinator list
```

Remove a project. Aliased to `rm`
``` bash
$ tmuxinator delete [project]
```

Remove all tmuxinator configs, aliases and scripts. Aliased to `i`
``` bash
$ tmuxinator implode
```

Examines your environment and identifies problems with your configuration
``` bash
$ tmuxinator doctor
```

Shows tmuxinator's help. Aliased to `h`
``` bash
$ tmuxinator help
```

Shows the shell commands that get executed for a project
```bash
$ tmuxinator debug [project]
```

Shows tmuxinator's version.
``` bash
$ tmuxinator version
```

## Contributing

To contribute, please read the [contributing guide](https://github.com/aziz/tmuxinator/blob/master/CONTRIBUTING.md).

## Copyright

Copyright (c) 2010-2013 Allen Bargi. See LICENSE for further details.
