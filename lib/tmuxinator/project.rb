module Tmuxinator
  class Project
    include Tmuxinator::Util

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

    def rvm
      yaml["rvm"]
    end

    def rbenv
      yaml["rbenv"]
    end

    def pre
      yaml["pre"]
    end

    def pre_window
      if yaml["rbenv"].present?
        "rbenv shell #{yaml["rbenv"]}"
      elsif yaml["rvm"].present?
        "rvm use #{yaml["rvm"]}"
      elsif yaml["pre_tab"].present?
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
      args = 
        if yaml["cli_args"].present?
          yaml["cli_args"]
        else
          yaml["tmux_options"]
        end

      if args.present?
        " #{args.strip}"
      else
        ""
      end
    end

    def base_index
      `tmux start-server\\\; show-window-options -g | grep pane-base-index`.split(/\s/).last.to_i
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
      deprecations << "DEPRECATION: The tabs option has been replaced by the window option and will not be supported in 0.8.0." if yaml["tabs"].present?
      deprecations << "DEPRECATION: The cli_args option has been replaced by the tmux_options option and will not be supported in 0.8.0." if yaml["cli_args"].present?
    end
  end
end
