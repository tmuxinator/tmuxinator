## Unreleased
- Replace erubis with erubi

## 3.0.0
### Misc
- Deprecate Ruby 2.5; bump min Ruby version in gemspec; bump Ruby versions in Travis test matrix
- Fix config file parsing error: wrong number of arguments (given 4, expected 1) (#819)

## 2.0.3
### Misc
- Add Ruby 3 to the Travis test matrix
- add support for tmux 3.2

## 2.0.2
### Misc
- add tmux 3.1c to Travis CI test matrix
- add Ruby support link and RVM/rbenv links to README (#707)
- add tmux 3.1b to Travis CI test matrix
- document support for unnamed windows in README (#773)

## 2.0.1
### Misc
- add support for tmux 3.1b

## 2.0.0
### Security
- bump rake development dependency version to address CVE-2020-8130
### Misc
- add support for tmux 3.1a
- document removal of Zsh mux alias; suggest users migrate to RC based aliases
- synchronize project configs in README and sample.yml
- remove support for Ruby 2.4
- bump patch versions of supported Rubies in gemspec and Travis config

## 1.1.5
### Misc
- add support for tmux 3.1 (#754)
- bump copyright year in README

## 1.1.4
### Misc
- bump Thor version to ~> 1.0 in order to accommodate Arch package and ecosystem
(#739)
- add Ruby 2.7.0 to Travis test matrix

### Bugfixes
- fix various completion script issues (#705/#737)

## 1.1.3
### Bugfixes
- correct edge tmux version detection (#728)

### Misc
- document local project creation (#439)
- add support for tmux 3.0 and 3.0a (#734)

## 1.1.2
### Bugfixes
- prevent commands from being re-run when re-attaching to session using custom
socket (#719)

### Misc
- add zshell completions for command aliases
- add note to README which covers temporary workaround for layout issues (#651)

## 1.1.1
### Bugfixes
- increase min XDG version in gemspec in order to exclude broken release (#708)

## 1.1.0
### Misc
- add support for tmux 2.9a

## 1.0.0
### Misc
- add support for tmux 2.9

## 0.16.0
### Bugfixes
- fix wemux class_eval error (#590)
### Misc
- drop support for ruby 2.3
- bump required_ruby_version
- bump test matrix patch versions
- Add `-n, [--newline], [--no-newline]` flag for list command
    Force output to be one entry per line
- make pre/post deprecation warnings more descriptive
- remove pre/post from project configuration template
- remove support for Ruby 2.2
- bundler version constraint now supports bundler >= 2 (required by TravisCI)

## 0.15.0
### Misc
- add support for Ruby 2.6 to the TravisCI test matrix
- add support for project config files using .yaml extension (#663)
- allow test suite to pass when $TMUXINATOR_CONFIG is set (#665)

## 0.14.0
### Misc
- Add `--suppress-tmux-version-warning` flag to prevent tmux version warning (#583)
- Separate version warning from deprecation messages
- Add unsupported version warnings for `stop` and `local` as well
- quiet deprecation warnings in test output (#619)
- reword "Project Configuration Location" section of README to reflect current
behavior (#621)
- correct some type on readme about aliases (#660)

## 0.13.0
### Bugfixes
- prevent optargs from being lost when using the project-config flag (#639)
- Add support for tmux 2.8 (#653)

## 0.12.0
### Bugfixes
- Fix zsh completion when there are no projects
- Run stop hook before killing the session

### Misc
- Allow YAML Anchors & Aliases as per [spec](http://yaml.org/spec/1.2/spec.html#id2765878)
- Remove confusing README section about the pane-base-index and
  window-base-index options. These options can be set independently of one
  another now that #542 and #543 are merged.

## 0.11.3
### Misc
- replace j3rn's email with ethagnawl's in COC
- use correct paths in generated config file comment (#440)

### Bugfixes
- fix "wrong namespace" RuboCop warnings (#620)
- fix [#431](https://github.com/tmuxinator/tmuxinator/issues/431), where Thor-based commands (e.g. "-v", "help") were failing

## 0.11.2
### Bugfixes
- Fix [#555](https://github.com/tmuxinator/tmuxinator/issues/555), restoring
  `on_project_exit` hook behaviour (same as deprecated `post`)

## 0.11.1
### Misc
- Add support for tmux 2.7 (#611)
- Fix load order when multiple versions of tmuxinator are installed (#603)

## 0.11.0
### Misc
- Make Config#xdg comment reference correct XDG variable and include example of
  degenerate case (#597)
- Introduce factory_bot, to replace factory_girl, which was renamed
  recently.
- Add Ruby 2.5 to the TravisCI test matrix and bump patch level of existing Rubies
  (2.2, 2.3, 2.4)
### New Features
- Add optional `--project-config=...` parameter to `tmuxinator start` (#595)

## 0.10.1
- Handle emojis in project names (#564)
- Fix remaining sites where the base-index option (for windows) was incorrectly
  used in place of the pane-base-index option.
- Treat 'tmux master' as an arbitrarily high version and display a deprecation
  warning for unsupported tmux versions (#524, #570)
- Add tmux 2.4, 2.5, and 2.6 to the TravisCI test matrix
- Updates `rubocop` to resolve security vulnerability

## 0.10.0
- Fix a bug causing the user's global pane-base-index setting not to be
  respected
- Remove Object#blank? monkey patch (#458)
- Add _Project Configuration Location_ entry to README (#360, #534)
- Attach original exception message to exception re-raised by Project::load
- Remove unused attr_readers from Tmuxinator::Window
- Add ability for pre_window commands to parse yaml arrays
- Refactor Tmuxinator::Config by extracting a Tmuxinator::Doctor class (#457)
- Fix a bug where startup_window and startup_pane were not respected if running
  tmuxinator from within an existing tmux session (#537)
- Fix a bug causing the pane-base-index option to override base-index

### Misc
- Removed support for Ruby 1.9.3, 2.0, & 2.1
- Move gem dependencies from Gemfile to tmuxinator.gemspec
- Add tmux 2.2 and 2.3 the TravisCI test matrix
- Fix typos
- Support user-specified and XDG Base Dirs configuration directories

### New Features
- add on_project_start, on_project_first_start, on_project_restart, on_project_exit and on_project_stop hooks for project

## 0.9.0
### Misc
- Temporarily hiding Shorthand entry in README.md to prevent new bug reports
  about the mux symlink being broken
- Use `alias` (bash, zsh) and `abbr` (fish) instead of a symlink to hash `mux`. #401
- replace instances of `File.exists?` (deprecated) with `File.exist?`
- Refactor Config.root

### New Features
- Allow multiple panes to be defined using yaml hash or array #266, #406
- Add `startup_pane` #380
- Add synchronizations panes support #97
- Add `before` and `after` options to synchronization functionality
- Add deprecation warning if `synchronize: true` or `before` is used

### Bugfixes
- Suppress `tmux ls` non-zero exit status/message when no sessions exist (#414)
- Will no longer crash when no panes are specified in a window
- Locking activesupport at < 5.0.0 to prevent broken builds on Ruby < 2.2.3
- Fixed whitespace issues in help

## 0.8.1
### Bugfixes

- Fixed broken shell completions

## 0.8.0
### New features

- Add support for deleting multiple projects at once, using `mux delete <p1> <p2> ...`
- Add stop command to kill tmux sessions

### Bugfixes

- Bugfix for issue with using numbers as window names
- Bugfix for zsh-completion loading throwing an error if tmuxinator is not yet available.
- Bugfix for using `mux delete` to delete local projects

## 0.7.2
- Bugfix for attaching to sessions by prefix when running `start`
- Bugfix for "pane could not be created" error

## 0.7.1
- Bugfix where `mux open` or similar would delete the contents of the file

## 0.7.0
### New features

- Add support for starting in detached mode #307
- Support windows without names #292, #323
- Add per project `.tmuxinator.yml` support #335 :sparkles:
- Support passing args on the command line #343 :tada:

### Bug fixes and Misc
- Fix some RSpec deprecations
- Explain what ERB is in the readme #319
- Prevent project names containing only numbers from raising a NoMethodError #324
- Fix YAML syntax highlighting in readme #325
- Add `asset_path` helper #326
- Switch to just plain Rubocop instead of hound #339
- Fix typo in readme #346
- Fix thor not returning correct exit status #192
- Add gitter badge

## 0.6.11
- Add aliasing of projects to create multiple sessions for a single project #143, #273
- ERB support for projects #267
- Post and attach options #293
- Fix typo in gemspec #294
- Fix completions not searching subdirectory #295
- Remove duplicate attribute #298
- Fix support for tmux 1.8 and below
- Project cleanup #311
- Fix error when no project name is provided #303

## 0.6.10
- Interpret config file as ERB template #255
- Fix zsh completions #262
- Alias `e` to edit and `o` to open #275
- Fix fish completions #280
- Add `startup_window` #282
- Add per window root option #283
- Fix project path detection #274
- Include completions in gemspec #270

## 0.6.9
- Update to RSpec 3.x
- Allow for earlier versions of thor #234, #235
- Remove dependency on git and fix warnings in gemspec #232, #233, #239
- Switch from `which` to `type` to stop errors in OSX 10.10 #236, #237
- Optional project root #185, #144
- Clear rbenv environment variables before starting tmux #208
- Update readme with correct fish completions path #247
- Escape path to deal with special characters #251, #256, #257
- Fix `copy` overwriting files #254, #258

## 0.6.8
- Remove some duplication #212
- Add wemux support #88 - Thanks to Andrew Thal (@athal7)
- Fix typos in readme #217, #216
- Fix encoding bug #229
- Fix specs not running due to changes in thor

## 0.6.7
- Remove use of grep for base-index #171
- Fix bugs in `Tmuxinator::Config.default?` #169
- Fix path for Rails log in directory sample #177
- Add completions for fish shell #179
- Fix grammar in readme #184
- Make commands take precedence over project names #182
- Improve error messages when $EDITOR isn't set #186, #194
- Add confirmation to deletion prompt #197
- Fix broken badge references after organisation move
- Remove dependency on ActiveSupport #199
- Fix compatibility with tmux 1.9

## 0.6.6
- Fix a bug caused by not escaping the root path #145
- Fix bash completion with a single argument #148
- Fix regression where an array of commands for a window wasn't working #149
- Add an option to call tmux wrappers or derivatives #154
- Refactor build\_panes to always return an array #157
- Clean up some branching code using `.presence` #163
- Setup TravisCI test matrix for different tmux versions #164
- Fix some grammar and spelling in readme #166
- Make multiple commands use tmux's `send-keys` rather than just using `&&` for both panes and windows #100

## 0.6.5
- Change deprecation continue message from any key to just the enter key
- Dramatically clean up the readme to be clearer for new users
- Update the contributing guide with references to the GitHub styleguide and add examples of how to leave good commit messages
- Use Erubis to render the project sample and fix a bad binding reference
- Update the sample project to be much simpler
- Fix not working delete command #142
- Fix an error in the bash completion script
- Fix an issue where the wrong project path was being returned
- Fix an issue where command aliases were being ignored

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
