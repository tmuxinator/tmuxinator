## 0.6.4.1
- Move slow completion scripts back to bin.
- Change deprecation continue key to just enter.

## 0.6.4
- Fixes broken backwards compatibility of multiple pre commands #129
- Fixes tmuxinator ignoring project root when started from within a tmux session #132
- Add gem version badge

## 0.6.3
- Remove stray pry #128
- Allow starting a tmuxinator project while inside a tmux session #130
- Set the tmux layout after pane creation to avoid pane too small errors #131
- Check for both pane-base-index and base-index #126

## 0.6.2
- Also pass command line options to the `base_index` lookup.
- Fixed bug #116.

## 0.6.1
- Remove stray binding.pry
- Fix nil error when creating a new project.

## 0.6.0

- Rewrote core functionality with proper abstractions and unit tests
- Fixed outstanding bugs #72 #89 #90 #93 #101 #102 #103 #104 #109
- Switched to thor for command line argument parsing
- Switched to Erubis for more Rails like ERB
- Added simplecov for test coverage
- Added debug command line option to view generated shell commands
- Added commands and completion options for completion scripts
- Added `pre_window` option for running commands before all panes and windows
- Deprecated `rbenv` in favour of `pre_window`
- Deprecated `rvm` in favour of `pre_window`
- Deprecated `cli_args` in favour of `tmux_options`
- Deprecated `tabs` in favour of `windows`
- Dropped support for Ruby 1.9.2

## 0.5.0
- Added optional socket name support (Thanks to Adam Walters)
- Added auto completion (Thanks to Jose Pablo Barrantes)

## 0.4.0
- Does not crash if given an invalid yaml file format. report it and exit gracefully.
- Removed clunky scripts & shell aliases (Thanks to Dane O'Connor)
- Config files are now rendered JIT (Thanks to Dane O'Connor)
- Can now start sessions from cli (Thanks to Dane O'Connor)

## 0.3.0
- Added pre command (Thanks to Ian Yang)
- Added multiple pre command (Thanks to Bjørn Arild Mæland)
- Using tmux set default-path for project root
- New aliases

## 0.2.0
- Added pane support (Thanks to Aaron Spiegel)
- RVM support (Thanks to Jay Adkisoon)

