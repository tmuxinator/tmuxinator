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
      windows_yml =
        if yaml["tabs"].present?
          yaml["tabs"]
        else
          yaml["windows"]
        end

      @windows ||= windows_yml.map.with_index do |window_yml, index|
        Tmuxinator::Window.new(window_yml, index, self)
      end
    end

    def root
      if yaml["project_root"].present?
        yaml["project_root"]
      else
        yaml["root"]
      end
    end

    def name
      if yaml["project_name"].present?
        yaml["project_name"].shellescape
      else
        yaml["name"].shellescape
      end
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
      "tmux#{tmux_options}#{socket}"
    end

    def socket
      if socket_path.present?
        " -S #{socket_path}"
      elsif socket_name.present?
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
      get_pane_base_index.present? ? get_pane_base_index.to_i : get_base_index.to_i
    end

    def tmux_options?
      yaml["tmux_options"].present?
    end

    def windows?
      windows.any?
    end

    def root?
      root.present?
    end

    def name?
      name.present?
    end

    def window(i)
      "#{name}:#{i}"
    end

    def send_pane_command(cmd, window_index, pane_index)
      if cmd.blank?
        ""
      else
        "#{tmux} send-keys -t #{window(window_index)} #{cmd.shellescape} C-m"
      end
    end

    def send_keys(cmd, window_index)
      if cmd.blank?
       ""
      else
        "#{tmux} send-keys -t #{window(window_index)} #{cmd.shellescape} C-m"
      end
    end

    def deprecations
      deprecations = []
      deprecations << "DEPRECATION: rbenv/rvm specific options have been replaced by the pre_tab option and will not be supported in 0.8.0." if yaml["rbenv"] || yaml["rvm"]
      deprecations << "DEPRECATION: The tabs option has been replaced by the windows option and will not be supported in 0.8.0." if yaml["tabs"].present?
      deprecations << "DEPRECATION: The cli_args option has been replaced by the tmux_options option and will not be supported in 0.8.0." if yaml["cli_args"].present?
      deprecations
    end

    def get_pane_base_index
      `#{tmux} start-server\\; show-option -g | grep pane-base-index`.split(/\s/).last
    end

    def get_base_index
      `#{tmux} start-server\\; show-option -g | grep base-index`.split(/\s/).last
    end
  end
end
