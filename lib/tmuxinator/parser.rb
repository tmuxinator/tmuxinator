# This is a very simple factory and delegator to allow parsing config files other than the Tmux standard format
# e.g. foreman's Procfile
# All calls to objects of this class are delegated to the parser
module Tmuxinator
  class Parser < SimpleDelegator
    def initialize(config_file, options = {}, type=nil)
      parser_klass = case type
      when 'procfile'
        Tmuxinator::Parsers::Procfile
      when 'default'
        Tmuxinator::Parsers::Default
      else
        raise "Invalid Parser Type"
      end

      parser = parser_klass.new(config_file, options)
      super(parser)
    end
  end
end
