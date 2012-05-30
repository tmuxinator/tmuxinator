module Tmuxinator

  class ConfigWriter
    attr_accessor :file_name, :file_path, :project_name, :project_root, :rvm, :tabs, :pre, :settings, :hotkeys
    attr_reader :argv

    include Tmuxinator::Helper

    def initialize this_full_path=nil, *argv
      @argv = strict_argv(argv)
      self.file_path = this_full_path if this_full_path
    end

    def file_path= full_path
      @file_path = full_path
      @file_name = File.basename full_path, '.yml'
      process_config! if full_path && File.exist?(full_path)
    end

    def write!
      raise "Unable to write with out a file_name defined" unless self.file_name
      tmp = File.open(config_path, 'w') {|f| f.write(render) }
    end

    def render
      ERB.new(IO.read(TMUX_TEMPLATE)).result(binding)
    end

    def config_path
      "#{root_dir}#{file_name}.tmux" if file_name
    end

    def socket
      "-L #{@socket_name}" if @socket_name
    end

    private

    def root_dir
      "$HOME/.tmuxinator/"
    end

    def processed_yaml
      interpolated = ERB.new(File.read(file_path)).result(binding)
      YAML.load(interpolated)
    end

    # Set up an array-like hash that raises on missing indices
    def strict_argv(args)
      strict = Hash.new {|_, key| raise IndexError, key}
      args.each_with_index {|arg, idx| strict[idx] = arg}
      strict
    end

    def process_config!
      begin 
        yaml = processed_yaml
      rescue IndexError => e
        exit!("argv missing index #{e.message}")
      rescue
        exit!("Invalid YAML file format.")
      end

      exit!("Your configuration file should include some tabs.")        if yaml["tabs"].nil?
      exit!("Your configuration file didn't specify a 'project_root'")  if yaml["project_root"].nil?
      exit!("Your configuration file didn't specify a 'project_name'")  if yaml["project_name"].nil?

      @project_name = yaml["project_name"]
      @project_root = yaml["project_root"]
      @rvm          = yaml["rvm"]
      @pre          = build_command(yaml["pre"])
      @tabs         = []
      @socket_name  = yaml['socket_name']
      @settings     = ensure_list(yaml['settings'])
      @hotkeys     = ensure_list(yaml['hotkeys'])

      yaml["tabs"].each do |tab|
        t       = OpenStruct.new
        t.name  = tab.keys.first
        value   = tab.values.first

        case value
        when Hash
          t.panes = (value["panes"] || ['']).map do |pane|
            build_command(pane)
          end
          t.layout = value["layout"]
          str = ( ( value["pre"] if value["pre"] && value["pre"].kind_of?(Array) ) || ([value["pre"]] if value["pre"] && value["pre"].kind_of?(String)) || ['']).map do |cmds|
            build_command(cmds, false)
          end.join ' && '
          t.pre = build_command(str)
        else
          t.command = build_command(value)
        end
        @tabs << t
      end
    end

    def parse_tabs tab_list
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
      "tmux #{socket} send-keys -t #{window(window_number)} #{s cmd} C-m"
    end

    def ensure_list(value)
      [value].flatten.compact.reject { |c| c.strip.empty? }
    end

    def build_command(value, rvm_prepend=true)
      commands = ensure_list(value)
      if @rvm && rvm_prepend
        commands.unshift "rvm use #{@rvm}"
      end
      commands.join ' && '
    end
  end

end
