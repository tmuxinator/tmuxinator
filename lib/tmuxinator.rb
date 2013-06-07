require "yaml"
require "erubis"
require "shellwords"
require "thor"
require "active_support/all"

require "tmuxinator/util"
require "tmuxinator/cli"
require "tmuxinator/config"
require "tmuxinator/pane"
require "tmuxinator/project"
require "tmuxinator/tab"
require "tmuxinator/version"

TMUX_TEMPLATE  = "#{File.dirname(__FILE__)}/tmuxinator/assets/tmux_config.tmux.erb"

module Tmuxinator
end
