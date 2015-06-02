module Tmuxinator
  class Pane
    attr_reader :commands, :project, :index, :tab

    def initialize(index, project, tab, *commands)
      @commands = commands
      @index = index
      @project = project
      @tab = tab
    end

    def tmux_window_and_pane_target
      "#{project.name}:#{tab.index + project.base_index}.#{index + project.base_index}"
    end

    def tmux_pre_command
      return unless tab.pre

      "#{project.tmux} send-keys -t #{tmux_window_and_pane_target} #{tab.pre.shellescape} C-m"
    end

    def tmux_pre_window_command
      return unless project.pre_window

      "#{project.tmux} send-keys -t #{tmux_window_and_pane_target} #{project.pre_window.shellescape} C-m"
    end

    def tmux_main_command(command)
      command ? "#{project.tmux} send-keys -t #{project.name}:#{tab.index + project.base_index}.#{index + tab.project.base_index} #{command.shellescape} C-m" : ""
    end

    def tmux_split_command
      path = tab.root? ? "#{Tmuxinator::Config.default_path_option} #{tab.root}" : nil
      "#{project.tmux} splitw #{path} -t #{tab.tmux_window_target}"
    end

    def last?
      index == tab.panes.length - 1
    end

    def multiple_commands?
      commands && commands.length > 0
    end
  end
end
