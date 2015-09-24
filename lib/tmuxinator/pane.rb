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
      x = tab.index + project.base_index
      y = index + project.base_index
      "#{project.name}:#{x}.#{y}"
    end

    def tmux_pre_command
      return unless tab.pre

      t = tmux_window_and_pane_target
      e = tab.pre.shellescape
      "#{project.tmux} send-keys -t #{t} #{e} C-m"
    end

    def tmux_pre_window_command
      return unless project.pre_window

      t = tmux_window_and_pane_target
      e = project.pre_window.shellescape
      "#{project.tmux} send-keys -t #{t} #{e} C-m"
    end

    def tmux_main_command(command)
      if command
        x = tab.index + project.base_index
        y = index + tab.project.base_index
        e = command.shellescape
        n = project.name
        "#{project.tmux} send-keys -t #{n}:#{x}.#{y} #{e} C-m"
      else
        ""
      end
    end

    def tmux_split_command
      path = if tab.root?
               "#{Tmuxinator::Config.default_path_option} #{tab.root}"
             end
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
