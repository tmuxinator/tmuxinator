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

    def tabs
      @tabs ||= if yaml["tabs"].present?
        yaml["tabs"].map do |tab_yaml|
          Tmuxinator::Tab.new(tab_yaml)
        end
      end
    end

    def root
      yaml["project_root"]
    end

    def name
      yaml["project_name"].shellescape
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

    def tmux
      "tmux#{socket}"
    end

    def attach
      cli_args.present? ? " #{cli_args}" : nil
      "tmux#{cli_args}#{socket} -u attach-session -t #{name}"
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

    def cli_args
      yaml["cli_args"]
    end

    def base_index
      %x[tmux show-window-options -g | grep pane-base-index].split(/\s/).last.to_i
    end

    def tabs?
      tabs.any?
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

    def send_keys(cmd, window_index)
      if cmd.blank?
       ""
      else
        "#{tmux} send-keys -t #{window(window_index)} #{cmd.shellescape} C-m"
      end
    end
  end
end
