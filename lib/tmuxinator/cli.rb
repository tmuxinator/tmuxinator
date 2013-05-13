require 'fileutils'

module Tmuxinator
  class Cli

    class << self
      include Tmuxinator::Helper

      def run *args
        if args.empty?
          if File.exists?(".tmuxinator")
            self.start_with_defaults 
          else
            self.usage
          end
        else
          self.send(args.shift, *args)
        end
      end

      # print the usage string, this is a fall through method.
      def usage
        puts %{
  Usage: tmuxinator ACTION [Arg]
  or
  tmuxinator [project_name]

  ACTIONS:
  start [project_name]
      start a tmux session using project's tmuxinator config
  open [project_name]
  new  [project_name]
      create a new project file and open it in your editor, aliases: new, n, o
  copy [source_project] [new_project]
      copy source_project project file to a new project called new_project
  delete [project_name]
      deletes the project called project_name
  implode
      deletes all existing projects!
  list [-v]
      list all existing projects
  doctor
      look for problems in your configuration
  help
      shows this help document
  version
      shows tmuxinator version number
}
      end
      alias :help :usage
      alias :h :usage

      # Open a config file, it's created if it doesn't exist already.
      def open *args
        exit!("You must specify a name for the new project") unless args.size > 0
        puts "warning: passing multiple arguments to open will be ignored" if args.size > 1
        @name = args.shift
        config_path = "#{root_dir}#{@name}.yml"
        unless File.exists?(config_path)
          template = File.exists?(user_config) ? user_config : sample_config
          erb      = ERB.new(File.read(template)).result(binding)
          File.open(config_path, 'w') {|f| f.write(erb) }
        end
        system("$EDITOR #{config_path}")
      end
      alias :o :open
      alias :new :open
      alias :n :open

      def copy *args
        @copy = args.shift
        @name = args.shift
        @config_to_copy = "#{root_dir}#{@copy}.yml"

        exit!("Project #{@copy} doesn't exist!")             unless File.exists?(@config_to_copy)
        exit!("You must specify a name for the new project") unless @name

        file_path = "#{root_dir}#{@name}.yml"

        if File.exists?(file_path)
          confirm!("#{@name} already exists, would you like to overwrite it? (type yes or no):") do
            FileUtils.rm(file_path)
            puts "Overwriting #{@name}"
          end
        end
        open @name
      end
      alias :c :copy
      alias :cp :copy

      def delete *args
        puts "warning: passing multiple arguments to delete will be ignored" if args.size > 1
        filename  = args.shift
        file_path = "#{root_dir}#{filename}.yml"

        if File.exists?(file_path)
          confirm!("Are you sure you want to delete #{filename}? (type yes or no):") do
            FileUtils.rm(file_path)
            puts "Deleted #{filename}"
          end
        else
          exit! "That file doesn't exist."
        end
      end
      alias :d :delete
      alias :rm :delete

      def implode *args
        exit!("delete_all doesn't accapt any arguments!") unless args.empty?
        confirm!("Are you sure you want to delete all tmuxinator configs? (type yes or no):") do
          FileUtils.remove_dir(root_dir)
          puts "Deleted #{root_dir}"
        end
      end
      alias :i :implode

      def list *args
        verbose = args.include?("-v")
        puts "tmuxinator configs:"
        Dir["#{root_dir}**"].sort.each do |path|
          next unless verbose || File.extname(path) == ".yml"
          path = path.gsub(root_dir, '').gsub('.yml','') unless verbose
          puts "    #{path}"
        end
      end
      alias :l :list
      alias :ls :list

      def version
        system("cat #{File.dirname(__FILE__) + '/../../VERSION'}")
        puts
      end
      alias :v :version

      def doctor
        print "  checking if tmux is installed ==> "
        puts system("which tmux > /dev/null") ?  "Yes" : "No"
        print "  checking if $EDITOR is set ==> "
        puts ENV['EDITOR'] ? "Yes" : "No"
        print "  checking if $SHELL is set ==> "
        puts ENV['SHELL'] ? "Yes" : "No"
      end

      # build script and run it
      def start *args
        exit!("You must specify a name for the new project") unless args.size > 0
        puts "warning: passing multiple arguments to open will be ignored" if args.size > 1
        project_name = args.shift
        config_path = "#{root_dir}#{project_name}.yml"
        config = Tmuxinator::ConfigWriter.new(config_path).render
        # replace current proccess with running compiled tmux config
        exec(config)
      end
      alias :s :start

      # use a .tmuxinator default file
      def start_with_defaults
        config_path = ".tmuxinator"
        config = Tmuxinator::ConfigWriter.new(config_path).render
        exec(config)
      end

      def method_missing method, *args, &block
        start method if File.exists?("#{root_dir}#{method}.yml")
        start_with_defaults if File.exists?(".tmuxinator")
        puts "There's no command or project '#{method}' in tmuxinator"
        usage
      end

      private #==============================

      def root_dir
        # create ~/.tmuxinator directory if it doesn't exist
        Dir.mkdir("#{ENV["HOME"]}/.tmuxinator/") unless File.directory?(File.expand_path("~/.tmuxinator"))
        sub_dir = File.join(File.expand_path(Dir.pwd), '.tmuxinator/')
        if File.directory?(sub_dir)
          return sub_dir
        else
          return "#{ENV["HOME"]}/.tmuxinator/"
        end
      end

      def sample_config
        "#{File.dirname(__FILE__)}/assets/sample.yml"
      end

      def user_config
        @config_to_copy || "#{ENV["HOME"]}/.tmuxinator/default.yml"
      end

    end

  end
end

