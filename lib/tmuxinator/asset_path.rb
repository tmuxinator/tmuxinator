module Tmuxinator
  class AssetPath
    class << self
      def sample
        asset_path "sample.yml"
      end

      def template
        asset_path "template.erb"
      end

      def stop_template
        asset_path "template-stop.erb"
      end

      def wemux_template
        asset_path "wemux_template.erb"
      end

      private

      def asset_path(asset)
        "#{File.dirname(__FILE__)}/assets/#{asset}"
      end
    end
  end
end
