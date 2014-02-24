module Tmuxinator
  class Project
    include Tmuxinator::Util
    include Tmuxinator::Deprecations

    attr_reader :yaml

    def initialize(yaml)
      @yaml = yaml
    end

    def render
      template = File.read(Tmuxinator::Config.template)
      Erubis::Eruby.new(template).result(binding)
    end

    def windows
      windows_yml = yaml["tabs"] || yaml["windows"]

      @windows ||= windows_yml.map.with_index do |window_yml, index|
        Tmuxinator::Window.new(window_yml, index, self)
      end
    end

    def root
      yaml["project_root"] || File.expand_path(yaml["root"])
    end

    def name
      yaml["project_name"] && yaml["project_name"].shellescape || yaml["name"].shellescape
    end

    def pre
      pre_config = yaml["pre"]
      if pre_config.is_a?(Array)
        pre_config.join("; ")
      else
        pre_config
      end
    end

    def pre_window
      if rbenv?
        "rbenv shell #{yaml["rbenv"]}"
      elsif rvm?
        "rvm use #{yaml["rvm"]}"
      elsif pre_tab?
        yaml["pre_tab"]
      else
        yaml["pre_window"]
      end
    end

    def tmux
      "#{tmux_command}#{tmux_options}#{socket}"
    end

    def tmux_command
      yaml["tmux_command"] || "tmux"
    end

    def socket
      if socket_path
        " -S #{socket_path}"
      elsif socket_name
        " -L #{socket_name}"
      else
        nil
      end
    end

    def socket_name
      yaml["socket_name"]
    end

    def socket_path
      yaml["socket_path"]
    end

    def tmux_options
      if cli_args?
        " #{yaml["cli_args"].to_s.strip}"
      elsif tmux_options?
        " #{yaml["tmux_options"].to_s.strip}"
      else
        ""
      end
    end

    def base_index
      get_pane_base_index ? get_pane_base_index.to_i : get_base_index.to_i
    end

    def tmux_options?
      yaml["tmux_options"]
    end

    def windows?
      windows.any?
    end

    def root?
      !root.nil?
    end

    def name?
      !name.nil?
    end

    def window(i)
      "#{name}:#{i}"
    end

    def send_pane_command(cmd, window_index, pane_index)
      if cmd.empty?
        ""
      else
        "#{tmux} send-keys -t #{window(window_index)} #{cmd.shellescape} C-m"
      end
    end

    def send_keys(cmd, window_index)
      if cmd.empty?
       ""
      else
        "#{tmux} send-keys -t #{window(window_index)} #{cmd.shellescape} C-m"
      end
    end

    def deprecations
      deprecations = []
      deprecations << "DEPRECATION: rbenv/rvm specific options have been replaced by the pre_tab option and will not be supported in 0.8.0." if yaml["rbenv"] || yaml["rvm"]
      deprecations << "DEPRECATION: The tabs option has been replaced by the windows option and will not be supported in 0.8.0." if yaml["tabs"]
      deprecations << "DEPRECATION: The cli_args option has been replaced by the tmux_options option and will not be supported in 0.8.0." if yaml["cli_args"]
      deprecations
    end

    def get_pane_base_index
      tmux_config["pane-base-index"]
    end

    def get_base_index
      tmux_config["base-index"]
    end

    def show_tmux_options
      "#{tmux} start-server\\; show-option -g"
    end

    private

    def tmux_config
      @tmux_config ||= extract_tmux_config
    end

    def extract_tmux_config
      options_hash = {}

      options_string = `#{show_tmux_options}`

      options_string.split("\n").map do |entry|
        key, value = entry.split("\s")
        options_hash[key] = value
        options_hash
      end

      options_hash
    end
  end
end
