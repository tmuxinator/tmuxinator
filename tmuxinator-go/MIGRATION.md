# Migration Guide: Ruby → Go

This guide covers migrating from the Ruby tmuxinator gem (v3.x) to the Go rewrite (v4.x).

## TL;DR

**Your existing configuration files work without any changes.**

The Go rewrite is a drop-in replacement. All YAML config files, shell completions, and command-line interfaces are fully backward compatible.

## What Changed

### Language & Runtime

| Aspect | Ruby (v3.x) | Go (v4.x) |
|--------|-------------|-----------|
| Runtime | Ruby ≥ 2.6 required | None (single binary) |
| Installation | `gem install tmuxinator` | Download binary or `go install` |
| Startup time | ~100-300ms | ~5-20ms |
| Memory usage | ~30-50MB | ~5-10MB |
| Binary size | N/A (gem) | ~8-12MB |

### Version Number

The version has been bumped to **4.0.0** to reflect the language change. The config file format and all commands remain identical.

### ERB Templates

The Ruby version used Ruby's ERB engine. The Go version implements a compatible subset:

| Feature | Ruby ERB | Go Implementation |
|---------|----------|-------------------|
| `<%= expr %>` | Full Ruby | Subset (see below) |
| `<% expr %>` | Full Ruby | Subset |
| `<%- -%>` | Whitespace trim | Supported |
| `@args[n]` | Ruby array | ✅ Supported |
| `@settings["key"]` | Ruby hash | ✅ Supported |
| `ENV["VAR"]` | Ruby ENV | ✅ Supported |
| Arbitrary Ruby | Full Ruby | ❌ Not supported |

**If your config uses arbitrary Ruby expressions** (beyond `@args`, `@settings`, and `ENV`), you will need to simplify them. Most configs only use these three patterns.

Example of supported ERB:

```yaml
# ✅ These work in the Go version
name: <%= @settings["name"] || "myproject" %>
root: <%= @settings["root"] || "~/projects" %>
windows:
  - editor: <%= @args[0] || "vim" %>
  - env: echo "User: <%= ENV["USER"] %>"
```

Example of unsupported ERB:

```yaml
# ❌ These require arbitrary Ruby and won't work
name: <%= File.basename(Dir.pwd) %>
root: <%= `git rev-parse --show-toplevel`.strip %>
```

**Workaround:** Use shell commands in your window/pane commands instead:

```yaml
# ✅ Equivalent workaround
name: myproject
windows:
  - setup: cd $(git rev-parse --show-toplevel)
```

## Installation

### Remove Ruby Version

```bash
gem uninstall tmuxinator
```

### Install Go Version

**Option 1: Download binary**

```bash
# macOS (Apple Silicon)
curl -L https://github.com/tmuxinator/tmuxinator/releases/latest/download/tmuxinator-darwin-arm64 \
  -o /usr/local/bin/tmuxinator
chmod +x /usr/local/bin/tmuxinator

# Linux (amd64)
curl -L https://github.com/tmuxinator/tmuxinator/releases/latest/download/tmuxinator-linux-amd64 \
  -o /usr/local/bin/tmuxinator
chmod +x /usr/local/bin/tmuxinator
```

**Option 2: Build from source**

```bash
git clone https://github.com/tmuxinator/tmuxinator
cd tmuxinator/tmuxinator-go
make install
```

**Option 3: Go install**

```bash
go install github.com/tmuxinator/tmuxinator/cmd/tmuxinator@latest
```

## Verifying the Migration

```bash
# Check version
tmuxinator version
# tmuxinator 4.0.0

# Check environment
tmuxinator doctor

# List your projects (should show same projects as before)
tmuxinator list

# Test a project (dry run)
tmuxinator debug myproject
```

## Shell Completions

The completion scripts are unchanged. If you were sourcing them from the gem path, update the path to point to the new location:

```bash
# Old (Ruby gem path)
source $(gem contents tmuxinator | grep completion/tmuxinator.bash)

# New (direct path)
source /path/to/tmuxinator-go/completion/tmuxinator.bash
```

## Rollback

If you need to roll back to the Ruby version:

```bash
gem install tmuxinator
# Remove the Go binary
rm /usr/local/bin/tmuxinator
# Reinstall Ruby version
gem install tmuxinator
```

## Reporting Issues

If you find a compatibility issue between the Ruby and Go versions, please [open an issue](https://github.com/tmuxinator/tmuxinator/issues) with:

1. Your config file (sanitized)
2. The command you ran
3. Expected output (from Ruby version)
4. Actual output (from Go version)

