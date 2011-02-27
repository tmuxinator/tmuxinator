require 'fileutils'

module Tmuxinator
  class Cli

    class << self
      include Tmuxinator::Helper

      def start *args
        if args.empty?
          self.usage
        else
          self.send(args.shift, *args)
        end
      end

      # print the usage string, this is a fall through method.
      def usage
        puts %{
  Usage: tmuxinator ACTION [Arg]

  ACTIONS:
  open [project_name]
      create a new project file and open it in your editor
  copy [source_project] [new_project]
      copy source_project project file to a new project called new_project
  delete [project_name]
      deletes the project called project_name
  implode
      deletes all existing projects!
  list [-v]
      list all existing projects
  help
      shows this help document
  version

}
      end
      alias :help :usage
      alias :h :usage

      # Open a config file, it's created if it doesn't exist already.
      def open *args
        exit!("You must specify a name for the new project") unless args.size > 0
        puts "warning: passing multiple arguments to open will be ignored" if args.size > 1
        @name = args.shift
        FileUtils.mkdir_p(root_dir+"scripts")
        config_path = "#{root_dir}#{@name}.yml"
        unless File.exists?(config_path)
          template = File.exists?(user_config) ? user_config : "#{File.dirname(__FILE__)}/assets/sample.yml"
          erb      = ERB.new(File.read(template)).result(binding)
          tmp      = File.open(config_path, 'w') {|f| f.write(erb) }
        end
        system("$EDITOR #{config_path}")
        update_scripts
      end
      alias :o :open

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
        Dir["#{root_dir}**"].each do |path|
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

      def update_scripts
        Dir["#{root_dir}*.tmux"].each {|p| FileUtils.rm(p) }
        aliases = []
        Dir["#{root_dir}*.yml"].each do |path|
          aliases << Tmuxinator::ConfigWriter.new(path).write!
        end
        Tmuxinator::ConfigWriter.write_aliases(aliases)
      end

      def doctor
        print "  cheking if tmux is installed ==> "
        puts system("which tmux > /dev/null") ?  "Yes" : "No" 
        print "  cheking if $EDITOR is set ==> "
        puts ENV['EDITOR'] ? "Yes" : "No"
        print "  cheking if $SHELL is set ==> "
        puts ENV['SHELL'] ? "Yes" : "No"
        puts %{
  make sure you have this line in your ~/.bashrc file:
  
  [[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator
      
      
}
      end

      def method_missing method, *args, &block
        puts "There's no command called #{method} in tmuxinator"
        usage
      end

      private #==============================

      def root_dir
        "#{ENV["HOME"]}/.tmuxinator/"
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

