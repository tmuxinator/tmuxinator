require "thor"
require "pry"

module Tmuxinator
  class Cli < Thor
    include Thor::Actions
    include Tmuxinator::Helper

    package_name "tmuxinator"

    desc "new [PROJECT]", "Create a new project file and open it in your editor"
    map "open" => :new
    map "o" => :new
    map "n" => :new

    def new(project)
      config = "#{Tmuxinator::Config.root}#{project}.yml"

      unless File.exists?(config)
        template = File.exists?(Tmuxinator::Config.default) ? Tmuxinator::Config.default : Tmuxinator::Config.sample
        erb  = ERB.new(File.read(template)).result(binding)
        File.open(config, "w") { |f| f.write(erb) }
      end

      Kernel.system("$EDITOR #{config}")
    end

    desc "start [PROJECT]", "Start a tmux session using a project's tmuxinator config"
    map "s" => :start

    def start(project)
      config = "#{Tmuxinator::Config.root}#{project}.yml"
      tmux = Tmuxinator::ConfigWriter.new(config).render

      Kernel.exec(tmux)
    end

    desc "copy [EXISTING] [NEW]", "Copy an existing project to a new project and open it in your editor"
    map "c" => :copy
    map "cp" => :copy

    def copy(existing, new)
      existing_config_path = "#{Tmuxinator::Config.root}#{existing}.yml"

      exit!("Project #{existing} doesn't exist!") unless File.exists?(existing_config_path)

      new_config_path = "#{Tmuxinator::Config.root}#{new}.yml"

      if File.exists?(new_config_path)
        if yes?("#{new} already exists, would you like to overwrite it?", :red)
          FileUtils.rm(new_config_path)
          say "Overwriting #{new}"
        end
      end

      FileUtils.copy_file(existing_config_path, new_config_path)
      Kernel.system("$EDITOR #{new_config_path}")
    end

    desc "delete [PROJECT]", "Deletes given project"
    map "d" => :delete
    map "rm" => :delete

    def delete(project)
      config =  "#{Tmuxinator::Config.root}#{project}.yml"

      if File.exists?(config)
        if yes?("Are you sure you want to delete #{project}?", :red)
          FileUtils.rm(config)
          say "Deleted #{project}"
        end
      else
        exit! "That file doesn't exist."
      end
    end

    desc "implode", "Delets all tmuxinator projects"
    map "i" => :implode

    def implode
      if yes?("Are you sure you want to delete all tmuxinator configs?", :red)
        FileUtils.remove_dir(Tmuxinator::Config.root)
        say "Deleted all tmuxinator projects."
      end
    end

    desc "list", "Lists all tmuxinator projects"
    map "l" => :list
    map "ls" => :list

    def list
      say "tmuxinator projects:"

      configs = Dir["#{Tmuxinator::Config.root}*.yml"].sort.map do |path|
        path.gsub(Tmuxinator::Config.root, "").gsub(".yml","") unless options.verbose?
      end

      print_in_columns configs
    end

    desc "version", "Display installed tmuxinator version"
    map "-v" => :version

    def version
      say "tmuxinator #{Tmuxinator::VERSION}"
    end

    desc "doctor", "Look for problems in your configuration"

    def doctor
      say "Checking if tmux is installed ==> "
      say_with_color Tmuxinator::Config.installed?

      say "Checking if $EDITOR is set ==> "
      say_with_color Tmuxinator::Config.editor?

      say "Checking if $SHELL is set ==> "
      say_with_color Tmuxinator::Config.shell?
    end

    no_tasks do
      def say_with_color(test)
        test ? say("Yes", :green) : say("No", :red)
      end
    end
  end
end
