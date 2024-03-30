# frozen_string_literal: true

module Tmuxinator
  class Pane
    attr_reader :commands, :project, :index, :tab, :title

    def initialize(index, project, tab, *commands, title: nil)
      @commands = commands
      @index = index
      @project = project
      @tab = tab
      @title = title.to_s.shellescape unless title.nil?
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

    def tmux_set_title
      unless title.nil?
        _set_title(title)
      end
    end

    def name
      project.name
    end

    def window_index
      tab.index + project.base_index
    end

    def pane_index
      index + tab.project.pane_base_index
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

    def _send_target(keys)
      _send_keys(tmux_window_and_pane_target, keys)
    end

    def _send_keys(target, keys)
      "#{project.tmux} send-keys -t #{target} #{keys} C-m"
    end

    def _set_title(title)
      target = tmux_window_and_pane_target
      "#{project.tmux} select-pane -t #{target} -T #{title}"
    end
  end
end
