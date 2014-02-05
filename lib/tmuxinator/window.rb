module Tmuxinator
  class Window
    include Tmuxinator::Util

    attr_reader :name, :panes, :layout, :commands, :index, :project, :path

    def initialize(window_yaml, index, project)
      @name = window_yaml.keys.first.present? ? window_yaml.keys.first.shellescape : nil
      @panes = []
      @layout = nil
      @pre = nil
      @project = project
      @index = index
      @path = project.root.shellescape

      value = window_yaml.values.first

      if value.is_a?(Hash)
        @index = value["index"] if value["index"].present?
        @layout = value["layout"].present? ? value["layout"].shellescape : nil
        @pre = value["pre"] if value["pre"].present?
        @path = value["path"].shellescape if value["path"].present?

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
          "#{tmux_window_command_prefix} #{command.shellescape} C-m" if command.present?
        end.compact
      elsif command_yml.present?
        ["#{tmux_window_command_prefix} #{command_yml.shellescape} C-m"]
      else
        []
      end
    end

    def pre
      if @pre.present?
        if @pre.is_a?(Array)
          @pre.join(" && ")
        elsif @pre.is_a?(String)
          @pre
        end
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
      project.pre_window.present? ? "#{project.tmux} send-keys -t #{tmux_window_target} #{project.pre_window.shellescape} C-m" : ""
    end

    def tmux_window_command_prefix
      "#{project.tmux} send-keys -t #{project.name}:#{index + project.base_index}"
    end

    def tmux_new_window_command
      "#{project.tmux} new-window -c #{path} -t #{tmux_window_target} -n #{name}"
    end

    def tmux_layout_command
      "#{project.tmux} select-layout -t #{tmux_window_target} #{layout}"
    end

    def tmux_select_first_pane
      "#{project.tmux} select-pane -t #{tmux_window_target}.#{panes.first.index + project.base_index}"
    end
  end
end
