# Tmuxinator

[![Gem Version](https://badge.fury.io/rb/tmuxinator.png)](http://badge.fury.io/rb/tmuxinator) [![Build Status](https://secure.travis-ci.org/aziz/tmuxinator.png)](http://travis-ci.org/aziz/tmuxinator?branch=master) [![Coverage Status](https://coveralls.io/repos/aziz/tmuxinator/badge.png)](https://coveralls.io/r/aziz/tmuxinator) [![Code Climate](https://codeclimate.com/github/aziz/tmuxinator.png)](https://codeclimate.com/github/aziz/tmuxinator) [![Dependency Status](https://gemnasium.com/aziz/tmuxinator.png)](https://gemnasium.com/aziz/tmuxinator)

Create and manage tmux sessions easily.

![Screenshot](https://f.cloud.github.com/assets/141213/916084/065fef7c-fe82-11e2-9c23-a9622c7d83c3.png)

## Installation

```
gem install tmuxinator
```

## Editor and Shell

tmuxinator uses your shell's default editor for opening files. If you're not
sure what that is type:

``` bash
echo $EDITOR
```

For me that produces "vim" If you want to change your default editor simply
put a line in ~/.bashrc that changes it. Mine looks like this:

```
export EDITOR='vim'
```

## tmux

The recommended version of tmux to use is 1.8. Your mileage may vary for
earlier versions. Refer to the FAQ for any odd behaviour.

### base-index

If you use a `base-index` other than the default, please be sure to also set the `pane-base-index`

```
set-window-option -g pane-base-index 1
```

## Completion

Download the appropriate completion file from the repo and `source` the file.
The following are example where the completion file has been downloaded into
`~/.bin`.

### bash

Add the following to your `~/.bashrc`:

    source ~/.bin/tmuxinator.bash

### zsh

Add the following to your `~/.zshrc`:

    source ~/.bin/tmuxinator.zsh

### fish

Move `tmuxinator.fish` to your `completions` folder:

    cp ~/.bin/tmuxinator.fish ~/.config/completions/

## Usage

A working knowledge of tmux is assumed. You should understand what windows and
panes are in tmux. If not please consult the [man pages](http://manpages.ubuntu.com/manpages/precise/en/man1/tmux.1.html#contenttoc6) for tmux.

### Create a project

Create or edit your projects with:

```
tmuxinator new [project]
```

For editing you can also use `tmuxinator open [project]`. `new` is aliased to
`o`,`open` and `n`. Your default editor (`$EDITOR`) is used to open the file.
If this is a new project you will see this default config:

```yaml
# ~/.tmuxinator/sample.yml

name: sample
root: ~/

# Optional. tmux socket
# socket_name: foo

# Runs before everything. Use it to start daemons etc.
# pre: sudo /etc/rc.d/mysqld start

# Runs in each window and pane before window/pane specific commands. Useful for setting up interpreter versions.
# pre_window: rbenv shell 2.0.0-p247

# Pass command line options to tmux. Useful for specifying a different tmux.conf.
# tmux_options: -f ~/.tmux.mac.conf

# Change the command to call tmux.  This can be used by derivatives/wrappers like byobu.
# tmux_command: byobu

windows:
  - editor:
      layout: main-vertical
      panes:
        - vim
        - guard
  - server: bundle exec rails s
  - logs: tail -f log/development.log
```

## Windows

The windows option allows the specfication of any number of tmux windows. Each window is denoted by a YAML array entry, followed by a name
and command to be run.

```
windows:
  - editor: vim
```

## Panes

**_Note that if you wish to use panes, make sure that you do not have `.` in your project name. tmux uses `.` to delimit between window and pane indicies,
and tmuxinator uses the project name in combination with these indicies to target the correct pane or window._**

Panes are optional and are children of window entries, but unlike windows, they do not need a name. In the following example, the `editor` window has 2 panes, one running vim, the other guard.

```yaml
windows:
  - editor:
      layout: main-vertical
      panes:
        - vim
        - guard
```

The layout setting gets handed down to tmux directly, so you can choose from
one of [the five standard layouts](http://manpages.ubuntu.com/manpages/precise/en/man1/tmux.1.html#contenttoc6)
or [specify your own](http://stackoverflow.com/a/9976282/183537).

## Interpreter Managers & Environment Variables

To use tmuxinator with rbenv, RVM, NVM etc, use the `pre_window` option.

```
pre_window: rbenv shell 2.0.0-p247
```

These command(s) will run before any subsequent commands in all panes and windows.

## Passing directly to send-keys

tmuxinator passes commands directly to send keys. This differs from simply chaining commands together using `&&` or `;`, in that
tmux will directly send the commands to a shell as if you typed them in. This allows commands to be executed on a remote server over
SSH for example.

To support this both the window and pane options can take an array as an argument:

```
name: sample
root: ~/

windows:
  - stats:
    - ssh stats@example.com
    - tail -f /var/log/stats.log
  - logs:
    layout: main-vertical
    panes:
      - logs:
        - ssh logs@example.com
        - cd /var/logs
        - tail -f development.log
```

## Starting a session

This will fire up tmux with all the tabs and panes you configured.

```
tmuxinator start [project]
```

## Shorthand

An shorthand alias for tmuxinator can also be used.

```
mux [command]
```

## Other Commands

Copy an existing project. Aliased to `c` and `cp`
```
tmuxinator copy [existing] [new]
```

List all the projects you have configured. Aliased to `l` and `ls`
```
tmuxinator list
```

Remove a project. Aliased to `rm`
```
tmuxinator delete [project]
```

Remove all tmuxinator configs, aliases and scripts. Aliased to `i`
```
tmuxinator implode
```

Examines your environment and identifies problems with your configuration
```
tmuxinator doctor
```

Shows tmuxinator's help. Aliased to `h`
```
tmuxinator help
```

Shows the shell commands that get executed for a project
```
tmuxinator debug [project]
```

Shows tmuxinator's version.
```
tmuxinator version
```

## FAQ

### Window names are not displaying properly?

Add `export DISABLE_AUTO_TITLE=true` to your `.zshrc` or `.bashrc`

### How can I ship a tmuxinator config with my project?

1. Include the config file in your project, e.g. for Rails, you could put it in config/tmuxinator.yml
2. Set your root relative to the config dir like: `root: "#{config_dir}/.."`
3. Specify the direct file path, e.g. `tmuxinator config/tmuxinator.yml"

## Contributing

To contribute, please read the [contributing guide](https://github.com/aziz/tmuxinator/blob/master/CONTRIBUTING.md).

## Copyright

Copyright (c) 2010-2013 Allen Bargi. See LICENSE for further details.
