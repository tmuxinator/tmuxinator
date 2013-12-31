require "yaml"
require "erubis"
require "shellwords"
require "thor"
require "thor/version"

require "tmuxinator/util"
require "tmuxinator/deprecations"
require "tmuxinator/wemux_support"
require "tmuxinator/cli"
require "tmuxinator/config"
require "tmuxinator/pane"
require "tmuxinator/project"
require "tmuxinator/window"
require "tmuxinator/version"

module Tmuxinator
end

class Object
  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end
end
