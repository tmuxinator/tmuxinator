module Tmuxinator
  class Config
    class << self
      def root
        Dir.mkdir("#{ENV["HOME"]}/.tmuxinator/") unless File.directory?(File.expand_path("~/.tmuxinator"))
        "#{ENV["HOME"]}/.tmuxinator/"
      end

      def sample
        "#{File.dirname(__FILE__)}/assets/sample.yml"
      end

      def default
        "#{ENV["HOME"]}/.tmuxinator/default.yml"
      end

      def installed?
        system("which tmux > /dev/null")
      end

      def editor?
        !ENV["EDITOR"].nil? && !ENV["EDITOR"].empty?
      end

      def shell?
        !ENV["SHELL"].nil? && !ENV["SHELL"].empty?
      end
    end
  end
end
