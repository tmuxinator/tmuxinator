module Tmuxinator
  class Config
    LOCAL_DEFAULT = "./.tmuxinator.yml".freeze
    NO_LOCAL_FILE_MSG = "Project file at ./.tmuxinator.yml doesn't exist."

    class << self
      def root
        root_dir = File.expand_path("~/.tmuxinator")
        Dir.mkdir("#{ENV['HOME']}/.tmuxinator") unless File.directory?(root_dir)
        "#{ENV['HOME']}/.tmuxinator"
      end

      def sample
        asset_path "sample.yml"
      end

      def default
        "#{ENV['HOME']}/.tmuxinator/default.yml"
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

      def local?
        project_in_local
      end

      def project_in_local
        [LOCAL_DEFAULT].detect { |f| File.exists?(f) }
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
