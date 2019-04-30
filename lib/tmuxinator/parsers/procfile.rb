module Tmuxinator
  module Parsers
    class Procfile
      def initialize(config_file, _options)
        @config_file = config_file
        @root = File.dirname(File.expand_path(config_file))
      end

      def build_yaml
        procfile_items = YAML.safe_load(File.read(@config_file), [], [], true)
        windows = build_windows_array(procfile_items)

        { "root" => @root, "name" => @name, "windows" => windows }
      end

      private

      # convert a hash into an array of those hash elements
      def build_windows_array(procfile_items)
        procfile_items.each_pair.inject([]) do |windows_array, hash_item|
          windows_array << { hash_item[0] => hash_item[1] }
        end
      end
    end
  end
end
