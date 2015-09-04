module Tmuxinator
  class Config
    LOCAL_DEFAULT = "./.tmuxinator.yml".freeze

    class << self
      def root
        Dir.mkdir("#{ENV["HOME"]}/.tmuxinator") unless File.directory?(File.expand_path("~/.tmuxinator"))
        "#{ENV["HOME"]}/.tmuxinator"
      end

      def sample
        asset_path "sample.yml"
      end

      def default
        "#{ENV["HOME"]}/.tmuxinator/default.yml"
      end

      def default?
        exists?("default")
      end

      def installed?
        Kernel.system("type tmux > /dev/null")
      end

      def version
        `tmux -V`.split(" ")[1].to_f if installed?
      end

      def default_path_option
        version && version < 1.8 ? "default-path" : "-c"
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

      def project_in_root(name)
        projects = Dir.glob("#{root}/**/*.yml")
        projects.detect { |project| File.basename(project, ".yml") == name }
      end

      def project_in_local(_name)
        [LOCAL_DEFAULT].detect { |f| File.exists?(f) }
      end

      def default_project(name)
        "#{root}/#{name}.yml"
      end

      def project(name)
        project_in_root(name) || project_in_local(name) || default_project(name)
      end

      def template
        asset_path "template.erb"
      end

      def wemux_template
        asset_path "wemux_template.erb"
      end

      def configs
        Dir["#{Tmuxinator::Config.root}/**/*.yml"].sort.map do |path|
          path.gsub("#{Tmuxinator::Config.root}/", "").gsub(".yml", "")
        end
      end

      def validate(name, options={})
        unless Tmuxinator::Config.exists?(name)
          puts "Project #{name} doesn't exist."
          exit!
        end

        config_path = Tmuxinator::Config.project(name)

        yaml = begin
          YAML.load(Erubis::Eruby.new(File.read(config_path)).result(binding))
        rescue SyntaxError, StandardError
          puts "Failed to parse config file. Please check your formatting."
          exit!
        end

        project = Tmuxinator::Project.new(yaml, options)

        unless project.windows?
          puts "Your project file should include some windows."
          exit!
        end

        unless project.name?
          puts "Your project file didn't specify a 'project_name'"
          exit!
        end

        project
      end

      private

        def asset_path(asset)
          "#{File.dirname(__FILE__)}/assets/#{asset}"
        end
    end
  end
end
