module Tmuxinator
  class Pane
    attr_reader :command, :project, :index, :project, :tab

    def initialize(command, index, project, tab)
      @command = command
      @index = index
      @project = project
      @tab = tab
    end

    def tmux_window_and_pane_target
      "#{project.name}:#{tab.index + project.base_index}.#{index + project.base_index}"
    end

    def tmux_pre_tab_command
      project.pre_tab.present? ? "#{project.tmux} send-keys -t #{tmux_window_and_pane_target} #{project.pre_tab.shellescape} C-m" : ""
    end

    def tmux_main_command
      command.present? ? "#{project.tmux} send-keys -t #{project.name}:#{tab.index + project.base_index}.#{index + tab.project.base_index} #{command.shellescape} C-m" : ""
    end

    def tmux_split_command
      "#{project.tmux} splitw -t #{tab.tmux_window_target}"
    end

    def last?
      index == tab.panes.length - 1
    end
  end
end
