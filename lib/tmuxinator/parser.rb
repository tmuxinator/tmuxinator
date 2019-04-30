# This is a very simple factory and delegator to allow parsing config files other than the Tmux standard format
# e.g. foreman's Procfile
# All calls to objects of this class are delegated to the parser
module Tmuxinator
  class Parser < SimpleDelegator
    def initialize(config_file, options = {}, type=nil)
      parser = case type
      when 'procfile'
        Parsers::Procfile
      else
        Parsers::Default
      end

      parser = klass.new(config_file, options)
      super(parser)
    end
  end
end
