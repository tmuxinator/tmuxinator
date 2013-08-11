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
        projects = Dir.glob("#{root}/**/*.yml")
        project_file = projects.detect { |project| project =~ /#{name}.yml/ }
        project_file || "#{root}/#{name}.yml"
      end

      def template
        "#{File.dirname(__FILE__)}/assets/template.erb"
      end

      def configs
        Dir["#{Tmuxinator::Config.root}/*.yml"].sort.map do |path|
          path.gsub("#{Tmuxinator::Config.root}/", "").gsub(".yml", "")
        end
      end

      def validate(name, per_project = false)
        unless Tmuxinator::Config.exists?(name) || File.exists?(name)
          puts "Project #{name} doesn't exist."
          exit!
        end

        config_path = per_project ? name : Tmuxinator::Config.project(name)

        yaml = begin
          YAML.load(File.read(config_path))
        rescue SyntaxError, StandardError
          puts "Failed to parse config file. Please check your formatting."
          exit!
        end

        project = Tmuxinator::Project.new(yaml)

        unless project.windows?
          puts "Your project file should include some windows."
          exit!
        end

        unless project.root?
          puts "Your project file didn't specify a 'project_root'"
          exit!
        end

        unless project.name?
          puts "Your project file didn't specify a 'project_name'"
        end

        project
      end
    end
  end
end
