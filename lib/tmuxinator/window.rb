module Tmuxinator
  class Window
    include Tmuxinator::Util

    attr_reader :name, :panes, :layout, :commands, :index, :project

    def initialize(window_yaml, index, project)
      @name = !window_yaml.keys.first.nil? ? window_yaml.keys.first.shellescape : nil
      @panes = []
      @layout = nil
      @pre = nil
      @project = project
      @index = index

      value = window_yaml.values.first

      if value.is_a?(Hash)
        @layout = value["layout"] ? value["layout"].shellescape : nil
        @pre = value["pre"] if value["pre"]

        @panes = build_panes(value["panes"])
      else
        @commands = build_commands(tmux_window_command_prefix, value)
      end
    end

    def build_panes(panes_yml)
      Array(panes_yml).map.with_index do |pane_yml, index|
        if pane_yml.is_a?(Hash)
          pane_yml.map do |name, commands|
            Tmuxinator::Pane.new(index, project, self, *commands)
          end
        else
          Tmuxinator::Pane.new(index, project, self, pane_yml)
        end
      end.flatten
    end

    def build_commands(prefix, command_yml)
      if command_yml.is_a?(Array)
        command_yml.map do |command|
          "#{tmux_window_command_prefix} #{command.shellescape} C-m" if command
        end.compact
      elsif command_yml.is_a?(String) && !command_yml.empty?
        ["#{tmux_window_command_prefix} #{command_yml.shellescape} C-m"]
      else
        []
      end
    end

    def pre
      if @pre.is_a?(Array)
        @pre.join(" && ")
      elsif @pre.is_a?(String)
        @pre
      else
        ""
      end
    end

    def panes?
      panes.any?
    end

    def tmux_window_target
      "#{project.name}:#{index + project.base_index}"
    end

    def tmux_pre_window_command
      project.pre_window ? "#{project.tmux} send-keys -t #{tmux_window_target} #{project.pre_window.shellescape} C-m" : ""
    end

    def tmux_window_command_prefix
      "#{project.tmux} send-keys -t #{project.name}:#{index + project.base_index}"
    end

    def tmux_new_window_command
      "#{project.tmux} new-window #{Tmuxinator::Config.default_path_option} #{File.expand_path(project.root).shellescape} -t #{tmux_window_target} -n #{name}"
    end

    def tmux_layout_command
      "#{project.tmux} select-layout -t #{tmux_window_target} #{layout}"
    end

    def tmux_select_first_pane
      "#{project.tmux} select-pane -t #{tmux_window_target}.#{panes.first.index + project.base_index}"
    end
  end
end
