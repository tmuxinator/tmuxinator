require "erubis"
require "fileutils"
require "shellwords"
require "thor"
require "thor/version"
require "xdg"
require "yaml"

module Tmuxinator
  SUPPORTED_TMUX_VERSIONS = [
    1.5,
    1.6,
    1.7,
    1.8,
    1.9,
    2.0,
    2.1,
    2.2,
    2.3,
    2.4,
    2.5,
    2.6,
    2.7
  ].freeze
end

require "tmuxinator/util"
require "tmuxinator/deprecations"
require "tmuxinator/wemux_support"
require "tmuxinator/cli"
require "tmuxinator/config"
require "tmuxinator/doctor"
require "tmuxinator/hooks"
require "tmuxinator/hooks/project"
require "tmuxinator/pane"
require "tmuxinator/project"
require "tmuxinator/window"
require "tmuxinator/version"
