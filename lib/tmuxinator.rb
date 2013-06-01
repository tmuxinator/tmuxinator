require "yaml"
require "ostruct"
require "erb"
require "active_support/all"
require "tmuxinator/util"
require "tmuxinator/config"
require "tmuxinator/cli"
require "tmuxinator/config_writer"
require "tmuxinator/version"

TMUX_TEMPLATE  = "#{File.dirname(__FILE__)}/tmuxinator/assets/tmux_config.tmux.erb"

module Tmuxinator
end
