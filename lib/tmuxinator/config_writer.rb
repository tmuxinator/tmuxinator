module Tmuxinator
  
  class ConfigWriter
    attr :file_name, :file_path, :project_name, :project_root, :rvm, :tabs
    
    include Tmuxinator::Helper
    
    def self.write_aliases aliases
      File.open("#{ENV["HOME"]}/.tmuxinator/scripts/tmuxinator", 'w') {|f| f.write(aliases.join("\n")) }
    end
    
    def initialize this_full_path=nil
      self.file_path = this_full_path if this_full_path
    end
    
    def file_path= full_path
      @file_path = full_path
      @file_name = File.basename full_path, '.yml'
      process_config! if full_path && File.exist?(full_path)
    end
    
    def write!
      raise "Unable to write with out a file_name defined" unless self.file_name
      erb         = ERB.new(IO.read(TMUX_TEMPLATE)).result(binding)
      tmp         = File.open(config_path, 'w') {|f| f.write(erb) }
      
      "alias start_#{file_name}='$SHELL #{config_path}'"
    end
    
    def config_path
      "#{root_dir}#{file_name}.tmux" if file_name
    end
    
    private
    
    def root_dir
      "#{ENV["HOME"]}/.tmuxinator/"
    end
    
    def process_config!
      yaml = YAML.load(File.read(file_path))

      exit!("Your configuration file should include some tabs.")        if yaml["tabs"].nil?
      exit!("Your configuration file didn't specify a 'project_root'")  if yaml["project_root"].nil?
      exit!("Your configuration file didn't specify a 'project_name'")  if yaml["project_name"].nil?
      
      @project_name = yaml["project_name"]
      @project_root = yaml["project_root"]
      @rvm          = yaml["rvm"]
      @tabs         = []
      
      yaml["tabs"].each do |tab|
        t       = OpenStruct.new
        t.name  = tab.keys.first
        value   = tab.values.first
        case value
        when Array
          value.unshift "rvm use #{@rvm}" if @rvm
          t.command = value.join(" && ")
        when String
          value = "rvm use #{@rvm} && #{value}" if @rvm
          t.command = value
        when Hash
          t.panes = (value["panes"] || ['']).map do |pane|
            if pane.is_a? Array
              pane.unshift! "rvm use #{@rvm}" if @rvm
              pane = pane.join(' && ')
            end
            pane = "rvm use #{@rvm} && #{pane}" if @rvm
            pane
          end
          t.layout = value["layout"]
        end
        @tabs << t
      end
    end

    def parse_tabs tab_list
    end
    
    def write_alias stuff
      File.open("#{root_dir}scripts/#{@filename}", 'w') {|f| f.write(stuff) }
    end

    def shell_escape str
      "'#{str.to_s.gsub("'") { %('\'') }}'"
    end
    alias s shell_escape

    def window(i)
      "#{s @project_name}:#{i}"
    end

    def send_keys cmd, window_number
      return '' unless cmd
      "tmux send-keys -t #{window(window_number)} #{s cmd} C-m"
    end
  end
  
end
