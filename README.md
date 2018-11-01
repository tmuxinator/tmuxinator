# Tmuxinator

[![Gem Version](https://badge.fury.io/rb/tmuxinator.svg)](http://badge.fury.io/rb/tmuxinator) [![Build Status](https://secure.travis-ci.org/tmuxinator/tmuxinator.png?branch=master)](http://travis-ci.org/tmuxinator/tmuxinator?branch=master) [![Coverage Status](https://img.shields.io/coveralls/tmuxinator/tmuxinator.svg)](https://coveralls.io/r/tmuxinator/tmuxinator?branch=master) [![Code Climate](https://codeclimate.com/github/tmuxinator/tmuxinator/badges/gpa.svg)](https://codeclimate.com/github/tmuxinator/tmuxinator) [![Dependency Status](https://gemnasium.com/tmuxinator/tmuxinator.svg)](https://gemnasium.com/tmuxinator/tmuxinator) [![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/tmuxinator/tmuxinator?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

Create and manage tmux sessions easily.

<table>
    <tbody>
        <tr align="center">
            <td>
                <img src="https://user-images.githubusercontent.com/289949/44366875-1a6cee00-a49c-11e8-9322-76e70df0c88b.gif" alt="Screenshot" width="80%" />
            </td>
        </tr>
    </tbody>
</table>

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

For me that produces "vim". If you want to change your default editor simply
put a line in ~/.bashrc that changes it. Mine looks like this:

```
export EDITOR='vim'
```

## tmux

The recommended version of tmux to use is 1.8 or later, with the exception of 2.5, which is **not** supported (see [issue 536](https://github.com/tmuxinator/tmuxinator/issues/536) for details). Your mileage may vary for
earlier versions. Refer to the FAQ for any odd behaviour.

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

    cp ~/.bin/tmuxinator.fish ~/.config/fish/completions/

## Usage

A working knowledge of tmux is assumed. You should understand what windows and
panes are in tmux. If not please consult the [man pages](http://manpages.ubuntu.com/manpages/precise/en/man1/tmux.1.html#contenttoc6) for tmux.

### Create a project

Create or edit your projects with:

```
tmuxinator new [project]
```

For editing you can also use `tmuxinator open [project]`. `new` is aliased to
`o`,`open`, `e`, `edit` and `n`. Please note that dots can't be used in project
names as tmux uses them internally to delimit between windows and panes.
Your default editor (`$EDITOR`) is used to open the file.
If this is a new project you will see this default config:

```yaml
# ~/.tmuxinator/sample.yml

name: sample
root: ~/

# Optional. tmux socket
# socket_name: foo

# Note that the pre and post options have been deprecated and will be replaced by
# project hooks.

# Project hooks

# Runs on project start, always
#on_project_start: command

# Run on project start, the first time
# on_project_first_start: command

# Run on project start, after the first time
# on_project_restart: command

# Run on project exit ( detaching from tmux session )
# on_project_exit: command

# Run on project stop
# on_project_stop: command

# Runs in each window and pane before window/pane specific commands. Useful for setting up interpreter versions.
# pre_window: rbenv shell 2.0.0-p247

# Pass command line options to tmux. Useful for specifying a different tmux.conf.
# tmux_options: -f ~/.tmux.mac.conf

# Change the command to call tmux.  This can be used by derivatives/wrappers like byobu.
# tmux_command: byobu

# Specifies (by name or index) which window will be selected on project startup. If not set, the first window is used.
# startup_window: logs

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

The windows option allows the specification of any number of tmux windows. Each window is denoted by a YAML array entry, followed by a name
and command to be run.

```yaml
windows:
  - editor: vim
```

### Window specific root

An optional root option can be specified per window:

```yaml
name: test
root: ~/projects/company

windows:
  - small_project:
      root: ~/projects/company/small_project
      panes:
        - start this
        - start that
```

This takes precedence over the main root option.

## Panes

**_Note that if you wish to use panes, make sure that you do not have `.` in your project name. tmux uses `.` to delimit between window and pane indices,
and tmuxinator uses the project name in combination with these indices to target the correct pane or window._**

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

**Please note the indentation here is deliberate. YAML's indentation rules can be confusing, so if your config isn't working as expected, please check the indentation.** For a more detailed explanation of _why_ YAML behaves this way, see [this](https://stackoverflow.com/questions/50594758/why-isnt-two-spaced-yaml-parsed-like-four-spaced-yaml/50600253#50600253) Stack Overflow question.

## Interpreter Managers & Environment Variables

To use tmuxinator with rbenv, RVM, NVM etc, use the `pre_window` option.

```yaml
pre_window: rbenv shell 2.0.0-p247
```

These command(s) will run before any subsequent commands in all panes and windows.

## Custom session attachment

You can set tmuxinator to skip auto-attaching to the session by using the `attach` option.

```yaml
attach: false
```
If you want to attach to tmux in a non-standard way (e.g. for a program that makes use of tmux control mode like iTerm2), you can run arbitrary commands by using a project hook:

```yaml
on_project_exit: tmux -CC attach
```

## Passing directly to send-keys

tmuxinator passes commands directly to send keys. This differs from simply chaining commands together using `&&` or `;`, in that
tmux will directly send the commands to a shell as if you typed them in. This allows commands to be executed on a remote server over
SSH for example.

To support this both the window and pane options can take an array as an argument:

```yaml
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

## ERB

Project files support [ERB](https://en.wikipedia.org/wiki/ERuby#erb) for reusability across environments. Eg:

```yaml
root: <%= ENV["MY_CUSTOM_DIR"] %>
```

You can also pass arguments to your projects, and access them with ERB. Simple arguments are available in an array named `@args`.

Eg:
```bash
$ tmuxinator start project foo
```

```yaml
# ~/.tmuxinator/project.yml

name: project
root: ~/<%= @args[0] %>

...
```

You can also pass key-value pairs using the format `key=value`. These will be available in a hash named `@settings`.

Eg:
```bash
$ tmuxinator start project workspace=~/workspace/todo
```

```yaml
# ~/.tmuxinator/project.yml

name: project
root: ~/<%= @settings["workspace"] %>

...
```

## Starting a session

This will fire up tmux with all the tabs and panes you configured, `start` is aliased to `s`.

```
tmuxinator start [project] -n [name] -p [project-config]
```

If you use the optional `[name]` argument, it will start a new tmux session with the custom name provided. This is to enable reuse of a project without tmux session name collision.

If there is a `./.tmuxinator.yml` file in the current working directory but not a named project file in `~/.tmuxinator`, tmuxinator will use the local file. This is primarily intended to be used for sharing tmux configurations in complex development environments.

You can provide tmuxinator with a project config file using the optional `[project-config]` argument (e.g. `--project-config=path/to/my-project.yaml` or `-p path/to/my-project.yaml`). This option will override a `[project]` name (if provided) and a local tmuxinator file (if present).

## Shorthand

The [shell completion files](#completion) also include a shorthand alias for tmuxinator that can be used in place of the full name.

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

## Project Configuration Location

Using environment variables, it's possible to house project configuration files
in non-standard directories. (See [PR #511](https://github.com/tmuxinator/tmuxinator/pull/511).)

Tmuxinator will attempt to use the following environment variables (in this
order) when creating or searching for existing project configuration files:

- `$TMUXINATOR_CONFIG`
- `$XDG_CONFIG_HOME/tmuxinator`
- `~/.tmuxinator`

This behavior is opt-in. If you do nothing, Tmuxinator will continue to use
`~/.tmuxinator` when searching for existing project configuration files or
creating new project configuration files.

## FAQ

### Window names are not displaying properly?

Add `export DISABLE_AUTO_TITLE=true` to your `.zshrc` or `.bashrc`

## Contributing

To contribute, please read the [contributing guide](https://github.com/tmuxinator/tmuxinator/blob/master/CONTRIBUTING.md).

## Copyright

Copyright (c) 2010-2018 Allen Bargi, Christopher Chow. See LICENSE for further details.
