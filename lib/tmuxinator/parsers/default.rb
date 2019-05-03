module Tmuxinator
  module Parsers
    class Default
      def initialize(config_file, options)
        @raw_content = File.read(config_file)

        args = options[:args] || []
        @settings = parse_settings(args)
        @args = args
      end

      def build_yaml
        content = Erubis::Eruby.new(@raw_content).result(binding)
        YAML.safe_load(content, [], [], true)
      end

      private

      def parse_settings(args)
        settings = args.select { |x| x.match(/.*=.*/) }
        args.reject! { |x| x.match(/.*=.*/) }

        settings.map! do |setting|
          parts = setting.split("=")
          [parts[0], parts[1]]
        end

        Hash[settings]
      end
    end
  end
end
