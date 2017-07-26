require "erubis"
require "fileutils"
require "shellwords"
require "thor"
require "thor/version"
require "xdg"
require "yaml"

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
require "tmuxinator/tmux_validator"

module Tmuxinator
end

class Object
  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end
end
