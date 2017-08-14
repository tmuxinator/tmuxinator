module Tmuxinator
  class Pane
    attr_reader :project, :index, :tab

    def initialize(index, title, project, tab, *commands)
      @commands = commands
      @title = title
      @index = index
      @project = project
      @tab = tab
    end

    def tmux_window_and_pane_target
      "#{project.name}:#{window_index}.#{pane_index}"
    end

    def tmux_pre_command
      _send_target(tab.pre.shellescape) if tab.pre
    end

    def tmux_pre_window_command
      _send_target(project.pre_window.shellescape) if project.pre_window
    end

    def tmux_main_command(command)
      if command
        _send_target(command.shellescape)
      else
        ""
      end
    end

    def commands
      if !@title.nil?
        [
          "printf '\\033]2;#{@title}\\033\\\\'",
          "clear"
        ] + @commands
      else
        @commands
      end
    end

    def name
      @title || project.name
    end

    def window_index
      tab.index + project.base_index
    end

    def pane_index
      index + tab.project.base_index
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

    private

    def _send_target(e)
      _send_keys(tmux_window_and_pane_target, e)
    end

    def _send_keys(t, e)
      "#{project.tmux} send-keys -t #{t} #{e} C-m"
    end
  end
end
