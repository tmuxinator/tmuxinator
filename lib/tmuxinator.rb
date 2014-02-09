require "yaml"
require "erubis"
require "shellwords"
require "thor"

class Object
  def try name
    __send__(name) if respond_to?(name)
  end
  def present?
    !nil?
  end
  def presence
    present? ? self : nil
  end
end
[String, Hash, Array].each do |klass|
  klass.class_eval do
    def present?
      !empty?
    end
  end
end

require "tmuxinator/util"
require "tmuxinator/deprecations"
require "tmuxinator/cli"
require "tmuxinator/config"
require "tmuxinator/pane"
require "tmuxinator/project"
require "tmuxinator/window"
require "tmuxinator/version"

module Tmuxinator
end
