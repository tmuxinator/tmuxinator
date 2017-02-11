module Tmuxinator
  class Config
    LOCAL_DEFAULT = "./.tmuxinator.yml".freeze
    CONFIG_DEFAULT = "#{ENV['HOME']}/.tmuxinator".freeze
    NO_LOCAL_FILE_MSG = "Project file at ./.tmuxinator.yml doesn't exist."

    class << self
      attr_writer :config_dir

      def config_dir
        @config_dir || CONFIG_DEFAULT
      end

      def root
        root_dir = File.expand_path(config_dir)
        Dir.mkdir(root_dir) unless File.directory?(root_dir)
        root_dir
      end

      def sample
        asset_path "sample.yml"
      end

      def default
        File.join(config_dir, "default.yml")
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
        File.exist?(project(name))
      end

      def project_in_root(name)
        projects = Dir.glob("#{root}/**/*.yml")
        projects.detect { |project| File.basename(project, ".yml") == name }
      end

      def local?
        project_in_local
      end

      def project_in_local
        [LOCAL_DEFAULT].detect { |f| File.exist?(f) }
      end

      def default_project(name)
        "#{root}/#{name}.yml"
      end

      def project(name)
        project_in_root(name) || project_in_local || default_project(name)
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

      def validate(options = {})
        name = options[:name]
        options[:force_attach] ||= false
        options[:force_detach] ||= false

        project_file = if name.nil?
                         raise NO_LOCAL_FILE_MSG \
                           unless Tmuxinator::Config.local?
                         project_in_local
                       else
                         raise "Project #{name} doesn't exist." \
                           unless Tmuxinator::Config.exists?(name)
                         Tmuxinator::Config.project(name)
                       end
        Tmuxinator::Project.load(project_file, options).validate!
      end

      private

      def asset_path(asset)
        "#{File.dirname(__FILE__)}/assets/#{asset}"
      end
    end
  end
end
