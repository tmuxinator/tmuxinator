module Tmuxinator
  class Tab
    attr_reader :name, :panes, :layout, :pre, :command, :index, :project

    def initialize(tab_yaml, index, project)
      @name = tab_yaml.keys.first.present? ? tab_yaml.keys.first.shellescape : nil
      @panes = []
      @layout = nil
      @pre = nil
      @command = nil
      @project = project
      @index = index

      value = tab_yaml.values.first

      if value.is_a?(Hash)
        @layout = value["layout"].present? ? value["layout"].shellescape : nil
        @pre = value["pre"] if value["pre"].present?

        @panes = build_panes(value["panes"])
      else
        @command = value
      end
    end

    def build_panes(pane_yml)
      if pane_yml.is_a?(Array)
        pane_yml.map.with_index do |pane_cmd, index|
          Tmuxinator::Pane.new(pane_cmd, index, project, self)
        end
      else
        Tmuxinator::Pane.new(pane_yml, index, project, self)
      end
    end

    def panes?
      panes.any?
    end

    def tmux_window_target
      "#{project.name}:#{index + project.base_index}"
    end

    def tmux_pre_tab_comamnd
      project.pre_tab.present? ? "#{project.tmux} send-keys -t #{tmux_window_target} #{project.pre_tab.shellescape} C-m" : ""
    end

    def tmux_main_command
      command.present? ? "#{project.tmux} send-keys -t #{project.name}:#{index + project.base_index} #{command.shellescape} C-m" : ""
    end

    def tmux_new_window_command
      "#{project.tmux} new-window -t #{tmux_window_target} -n #{name}"
    end

    def tmux_layout_command
      "#{project.tmux} select-layout -t #{tmux_window_target} #{layout}"
    end

    def tmux_select_first_pane
      "#{project.tmux} select-pane -t #{tmux_window_target}.#{panes.first.index + project.base_index}"
    end
  end
end
