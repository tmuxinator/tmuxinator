module Tmuxinator
  class Project
    include Tmuxinator::Util

    attr_reader :yaml

    def initialize(yaml)
      @yaml = yaml
    end

    def render
      ERB.new(IO.read(TMUX_TEMPLATE)).result(binding)
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

    def socket_name
      yaml["socket_name"]
    end

    def socket
      if socket_path.present?
        "-S #{@socket_path}"
      elsif socket_name.present?
        "-L #{@socket_name}"
      else
        ""
      end
    end

    def socket_path
      yaml["socket_path"]
    end

    def cli_args
      yaml["cli_args"]
    end

    def base_index
      yaml["base_index"].to_i
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

    def base_index?
      base_index.present?
    end

    def window(i)
      "#{name}:#{i}"
    end

    def send_keys(cmd, window_index)
      if cmd.blank?
       ""
      else
        "tmux #{socket} send-keys -t #{window(window_index)} #{cmd.shellescape} C-m"
      end
    end
  end
end
