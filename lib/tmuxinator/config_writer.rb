module Tmuxinator
  
  class ConfigWriter
    
    include Tmuxinator::Helper
    
    def self.write_aliases(aliases)
      File.open("#{ENV["HOME"]}/.tmuxinator/scripts/tmuxinator", 'w') {|f| f.write(aliases.join("\n")) }
    end
    
    def initialize(filename)
      @filename  = filename
      @file_path = "#{root_dir}#{@filename}.yml"
      process_config!
    end
    
    def write!
      template    = "#{File.dirname(__FILE__)}/assets/tmux_config.tmux"
      erb         = ERB.new(IO.read(template)).result(binding)
      config_path = "#{root_dir}#{@filename}.tmux"
      tmp         = File.open(config_path, 'w') {|f| f.write(erb) }
      
      "alias start_#{@filename}='$SHELL #{config_path}'"
    end
    
    private
    
    def root_dir
      "#{ENV["HOME"]}/.tmuxinator/"
    end
    
    def process_config!
      yaml = YAML.load(File.read(@file_path))

      exit!("Your configuration file should include some tabs.")        if yaml["tabs"].nil?
      exit!("Your configuration file didn't specify a 'project_root'")  if yaml["project_root"].nil?
      exit!("Your configuration file didn't specify a 'project_name'")  if yaml["project_name"].nil?
      
      @project_name = yaml["project_name"]
      @project_root = yaml["project_root"]
      @tabs         = []
      
      yaml["tabs"].each do |tab|
        t       = OpenStruct.new
        t.name  = tab.keys.first
        value   = tab.values.first
        t.stuff = value.is_a?(Array) ? value.join(" && ") : value
        @tabs << t
      end
      
    end
    
    def write_alias(stuff)
      File.open("#{root_dir}scripts/#{@filename}", 'w') {|f| f.write(stuff) }
    end
  end
  
end