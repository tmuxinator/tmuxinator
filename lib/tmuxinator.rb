require 'yaml'
require 'ostruct'
require 'erb'
require 'tmuxinator/helper'
require 'tmuxinator/cli'
require 'tmuxinator/config_writer'

TMUX_TEMPLATE  = "#{File.dirname(__FILE__)}/tmuxinator/assets/tmux_config.tmux"

module Tmuxinator
end
