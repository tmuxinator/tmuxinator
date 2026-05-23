# Tmuxinator (Go)

[![Go Version](https://img.shields.io/badge/go-1.21+-blue.svg)](https://golang.org)
[![Version](https://img.shields.io/badge/version-4.0.0-green.svg)](VERSION)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](../LICENSE)

A complete Go rewrite of [tmuxinator](https://github.com/tmuxinator/tmuxinator) — manage complex tmux sessions easily using YAML configuration files.

## Why Go?

- **Single binary** — no Ruby runtime required
- **Faster startup** — native compilation, no interpreter overhead
- **Easier distribution** — download and run, no `gem install`
- **Cross-platform** — macOS, Linux, Windows
- **100% backward compatible** — existing `~/.config/tmuxinator/` configs work unchanged

## Installation

### Download Binary

Download the latest release for your platform from the [releases page](https://github.com/tmuxinator/tmuxinator/releases):

```bash
# macOS (Apple Silicon)
curl -L https://github.com/tmuxinator/tmuxinator/releases/latest/download/tmuxinator-darwin-arm64 -o /usr/local/bin/tmuxinator
chmod +x /usr/local/bin/tmuxinator

# macOS (Intel)
curl -L https://github.com/tmuxinator/tmuxinator/releases/latest/download/tmuxinator-darwin-amd64 -o /usr/local/bin/tmuxinator
chmod +x /usr/local/bin/tmuxinator

# Linux (amd64)
curl -L https://github.com/tmuxinator/tmuxinator/releases/latest/download/tmuxinator-linux-amd64 -o /usr/local/bin/tmuxinator
chmod +x /usr/local/bin/tmuxinator
```

### Build from Source

```bash
git clone https://github.com/tmuxinator/tmuxinator
cd tmuxinator/tmuxinator-go
make build
# Binary is at build/tmuxinator
```

### Install via Go

```bash
go install github.com/tmuxinator/tmuxinator/cmd/tmuxinator@latest
```

## Requirements

- [tmux](https://github.com/tmux/tmux) (version 1.5+)
- `$EDITOR` environment variable set (for `new`/`edit` commands)

## Quick Start

```bash
# Create a new project
tmuxinator new myproject

# Start the session
tmuxinator start myproject

# Stop the session
tmuxinator stop myproject
```

## Configuration

Tmuxinator looks for project files in this order:

1. `$TMUXINATOR_CONFIG` (if set)
2. `$XDG_CONFIG_HOME/tmuxinator` (default: `~/.config/tmuxinator`)
3. `~/.tmuxinator`
4. `./.tmuxinator.yml` or `./.tmuxinator.yaml` (local project)

### Sample Configuration

```yaml
# ~/.config/tmuxinator/myproject.yml

name: myproject
root: ~/projects/myproject

# Optional tmux socket
# socket_name: foo

# Project hooks
on_project_start: echo "Starting myproject"
on_project_first_start: bundle install
on_project_restart: echo "Restarting"
on_project_exit: echo "Exiting"
on_project_stop: echo "Stopping"

# Runs in each window/pane before window-specific commands
pre_window: rbenv shell 2.0.0-p247

# Pass command line options to tmux
tmux_options: -f ~/.tmux.mac.conf

# Change the tmux command (e.g. for byobu/wemux)
# tmux_command: byobu

# Startup window/pane
startup_window: editor
startup_pane: 1

# Auto-attach after creation (default: true)
attach: true

windows:
  - editor:
      layout: main-vertical
      panes:
        - vim
        - guard
  - server: bundle exec rails s
  - logs: tail -f log/development.log
```

## Commands

| Command | Aliases | Description |
|---------|---------|-------------|
| `start [PROJECT] [ARGS]` | `s` | Start a tmux session |
| `stop [PROJECT]` | `st` | Stop a tmux session |
| `stop-all` | | Stop all active tmuxinator sessions |
| `new [PROJECT]` | `n`, `open`, `o` | Create a new project |
| `edit [PROJECT]` | `e` | Edit an existing project |
| `copy [EXISTING] [NEW]` | `c`, `cp` | Copy a project |
| `delete [PROJECT...]` | `d`, `rm` | Delete project(s) |
| `implode` | `i` | Delete all projects |
| `list` | `l`, `ls` | List all projects |
| `local` | `.` | Start session from `./.tmuxinator.yml` |
| `debug [PROJECT]` | | Show generated shell commands |
| `doctor` | | Check environment setup |
| `commands` | | List available commands |
| `completions [arg]` | | Shell completion helper |
| `version` | `-v` | Show version |

### Start Options

```bash
tmuxinator start myproject              # Start a project
tmuxinator start myproject -n mysession # Use a custom session name
tmuxinator start -p /path/to/config.yml # Use a specific config file
tmuxinator start myproject -a           # Force attach
tmuxinator start myproject --append     # Append to current session
tmuxinator start myproject --no-pre-window  # Skip pre_window commands
tmuxinator start myproject key=value    # Pass settings to ERB templates
tmuxinator start myproject arg1 arg2    # Pass positional args to ERB templates
```

### Shorthand

If the first argument is a known project name, `start` is implied:

```bash
tmuxinator myproject        # Same as: tmuxinator start myproject
tmuxinator myproject arg1   # Same as: tmuxinator start myproject arg1
```

If no arguments are given and `./.tmuxinator.yml` exists, it is started automatically:

```bash
cd ~/projects/myproject
tmuxinator                  # Same as: tmuxinator local
```

## ERB Template Support

Project files support ERB-like template syntax for dynamic configuration:

```yaml
name: myproject
root: <%= @settings["root"] || "~/projects" %>

windows:
  - editor: <%= @args[0] || "vim" %>
  - server: bundle exec rails s -p <%= @settings["port"] || "3000" %>
  - env: echo "User is <%= ENV["USER"] %>"
```

Pass arguments at runtime:

```bash
tmuxinator start myproject root=/home/user/myapp port=4000 vim
# @args[0] = "vim"
# @settings["root"] = "/home/user/myapp"
# @settings["port"] = "4000"
```

## Shell Completion

### Bash

Add to `~/.bashrc`:

```bash
source /path/to/tmuxinator-go/completion/tmuxinator.bash
```

### Zsh

Add to `~/.zshrc`:

```zsh
source /path/to/tmuxinator-go/completion/tmuxinator.zsh
```

### Fish

Copy to Fish completions directory:

```fish
cp /path/to/tmuxinator-go/completion/tmuxinator.fish ~/.config/fish/completions/
```

## Building

```bash
# Build for current platform
make build

# Run tests
make test

# Run tests with coverage
make test-cover

# Build release binaries for all platforms
make release

# Install to $GOPATH/bin
make install
```

## Migration from Ruby Version

See [MIGRATION.md](MIGRATION.md) for a complete migration guide.

**TL;DR:** Your existing `~/.config/tmuxinator/*.yml` files work without any changes.

## Compatibility

| Feature | Supported |
|---------|-----------|
| YAML config files | ✅ Full compatibility |
| ERB templates (`@args`, `@settings`, `ENV`) | ✅ |
| All 5 project hooks | ✅ |
| Pane titles (tmux ≥ 2.6) | ✅ |
| Wemux (`tmux_command: wemux`) | ✅ |
| Local projects (`.tmuxinator.yml`) | ✅ |
| Shell completion (bash/zsh/fish) | ✅ |
| Pre-window commands | ✅ |
| Append mode (`--append`) | ✅ |
| Socket name/path | ✅ |
| Synchronize panes | ✅ |
| Focused pane | ✅ |
| Startup window/pane | ✅ |
| Deprecation warnings | ✅ |

## License

MIT License — Copyright 2010-2025 Allen Bargi, Christopher Chow

See [LICENSE](../LICENSE) for details.

