module Tmuxinator
  class Config
    LOCAL_DEFAULTS = ["./.tmuxinator.yml", "./.tmuxinator.yaml"].freeze
    NO_LOCAL_FILE_MSG =
      "Project file at ./.tmuxinator.yml doesn't exist.".freeze
    NO_PROJECT_FOUND_MSG = "Project could not be found.".freeze
    TMUX_MASTER_VERSION = Float::INFINITY

    class << self
      # The directory (created if needed) in which to store new projects
      def directory
        return environment if environment?
        return xdg if xdg?
        return home if home?
        # No project directory specified or existant, default to XDG:
        FileUtils::mkdir_p(xdg)
        xdg
      end

      def home
        ENV["HOME"] + "/.tmuxinator"
      end

      def home?
        File.directory?(home)
      end

      # ~/.config/tmuxinator unless $XDG_CONFIG_HOME has been configured to use
      # a custom value. (e.g. if $XDG_CONFIG_HOME is set to ~/my-config, the
      # return value will be ~/my-config/tmuxinator)
      def xdg
        XDG["CONFIG"].to_s + "/tmuxinator"
      end

      def xdg?
        File.directory?(xdg)
      end

      # $TMUXINATOR_CONFIG (and create directory) or "".
      def environment
        environment = ENV["TMUXINATOR_CONFIG"]
        return "" if environment.to_s.empty? # variable is unset (nil) or blank
        FileUtils::mkdir_p(environment) unless File.directory?(environment)
        environment
      end

      def environment?
        File.directory?(environment)
      end

      def sample
        asset_path "sample.yml"
      end

      def default
        "#{directory}/default.yml"
      end

      def default?
        exists?(name: "default")
      end

      def version
        if Tmuxinator::Doctor.installed?
          tmux_version = `tmux -V`.split(" ")[1]

          if tmux_version == "master"
            TMUX_MASTER_VERSION
          else
            tmux_version.to_s[/\d+(?:\.\d+)?/, 0].to_f
          end
        end
      end

      def default_path_option
        version && version < 1.8 ? "default-path" : "-c"
      end

      def exists?(name: nil, path: nil)
        return File.exist?(path) if path
        return File.exist?(project(name)) if name
        false
      end

      def local?
        local_project
      end

      # Pathname of given project searching only global directories
      def global_project(name)
        project_in(environment, name) ||
          project_in(xdg, name) ||
          project_in(home, name)
      end

      def local_project
        LOCAL_DEFAULTS.detect { |f| File.exist?(f) }
      end

      def default_project(name)
        "#{directory}/#{name}.yml"
      end

      # Pathname of the given project
      def project(name)
        global_project(name) || local_project || default_project(name)
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

      # Sorted list of all .yml files, including duplicates
      def configs
        directories.map do |directory|
          Dir["#{directory}/**/*.yml"].map do |path|
            path.gsub("#{directory}/", "").gsub(".yml", "")
          end
        end.flatten.sort
      end

      # Existant directories which may contain project files
      # Listed in search order
      # Used by `implode` and `list` commands
      def directories
        if environment?
          [environment]
        else
          [xdg, home].select { |d| File.directory? d }
        end
      end

      def valid_project_config?(project_config)
        return false unless project_config
        unless exists?(path: project_config)
          raise "Project config (#{project_config}) doesn't exist."
        end
        true
      end

      def valid_local_project?(name)
        return false if name
        raise NO_LOCAL_FILE_MSG unless local?
        true
      end

      def valid_standard_project?(name)
        return false unless name
        raise "Project #{name} doesn't exist." unless exists?(name: name)
        true
      end

      def validate(options = {})
        name = options[:name]
        options[:force_attach] ||= false
        options[:force_detach] ||= false
        project_config = options.fetch(:project_config) { false }
        project_file = if valid_project_config?(project_config)
                         project_config
                       elsif valid_local_project?(name)
                         local_project
                       elsif valid_standard_project?(name)
                         project(name)
                       else
                         # This branch should never be reached,
                         # but just in case ...
                         raise NO_PROJECT_FOUND_MSG
                       end

        Tmuxinator::Project.load(project_file, options).validate!
      end

      # Deprecated methods: ignore the 1st, use the 2nd
      alias :root             :directory
      alias :project_in_root  :global_project
      alias :project_in_local :local_project

      private

      def asset_path(asset)
        "#{File.dirname(__FILE__)}/assets/#{asset}"
      end

      # The first pathname of the project named 'name' found while
      # recursively searching 'directory'
      def project_in(directory, name)
        return nil if String(directory).empty?
        projects = Dir.glob("#{directory}/**/*.{yml,yaml}").sort
        projects.detect { |project| File.basename(project, ".*") == name }
      end
    end
  end
end
