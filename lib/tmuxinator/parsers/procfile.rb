module Tmuxinator
  module Parsers
    class Procfile
      def initialize(config_file, _options)
        @config_file = config_file
      end

      def build_yaml
        YAML.safe_load(File.read(@config_file), [], [], true)
      end
    end
  end
end
