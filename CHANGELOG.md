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
- Explain what EBR is in the readme #319
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
- Remove dependancy on ActiveSupport #199
- Fix compatability with tmux 1.9

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

