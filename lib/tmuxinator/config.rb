module Tmuxinator
  class Config
    class << self
      def root
        Dir.mkdir("#{ENV["HOME"]}/.tmuxinator") unless File.directory?(File.expand_path("~/.tmuxinator"))
        "#{ENV["HOME"]}/.tmuxinator"
      end

      def sample
        "#{File.dirname(__FILE__)}/assets/sample.yml"
      end

      def default
        "#{ENV["HOME"]}/.tmuxinator/default.yml"
      end

      def default?
        exists?(default)
      end

      def installed?
        Kernel.system("which tmux > /dev/null")
      end

      def editor?
        !ENV["EDITOR"].nil? && !ENV["EDITOR"].empty?
      end

      def shell?
        !ENV["SHELL"].nil? && !ENV["SHELL"].empty?
      end

      def exists?(name)
        File.exists?(project(name))
      end

      def project(name)
        "#{root}/#{name}.yml"
      end
    end
  end
end
