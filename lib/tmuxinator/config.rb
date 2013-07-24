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
        unless project(name).nil?
          File.exists?(project(name))
        else
          false
        end
      end

      def project(name)
        projects = Dir.glob("#{root}/**/*.yml")
        projects.select { |project| project =~ /#{name}.yml/ }.first
      end

      def template
        "#{File.dirname(__FILE__)}/assets/template.erb"
      end
    end
  end
end
