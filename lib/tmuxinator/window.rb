# frozen_string_literal: true

module Tmuxinator
  class Window
    include Tmuxinator::Util

    attr_reader :commands, :index, :name, :project

    def initialize(window_yaml, index, project)
      first_key = window_yaml.keys.first

      @name = first_key.to_s.shellescape unless first_key.nil?
      @yaml = window_yaml.values.first
      @project = project
      @index = index
      @commands = build_commands(tmux_window_command_prefix, @yaml)
    end

    def panes
      @panes ||= build_panes(yaml["panes"]) || []
    end

    def _hashed?
      @yaml.is_a?(Hash)
    end

    def yaml
      _hashed? ? @yaml : {}
    end

    def layout
      yaml["layout"]&.shellescape
    end

    def synchronize
      yaml["synchronize"] || false
    end

    # The expanded, joined window root path
    # Relative paths are joined to the project root
    def root
      return _project_root unless _yaml_root

      File.expand_path(_yaml_root, _project_root).shellescape
    end

    def _yaml_root
      yaml["root"]
    end

    def _project_root
      project.root if project.root?
    end

    def build_panes(panes_yml)
      return if panes_yml.nil?

      Array(panes_yml).map.with_index do |pane_yml, index|
        commands, title = case pane_yml
                          when Hash
                            [pane_yml.values.first, pane_yml.keys.first]
                          when Array
                            [pane_yml, nil]
                          else
                            [pane_yml, nil]
                          end

        Tmuxinator::Pane.new(index, project, self, *commands, title: title)
      end.flatten
    end

    def build_commands(_prefix, command_yml)
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
      _pre = yaml["pre"]

      if _pre.is_a?(Array)
        _pre.join(" && ")
      elsif _pre.is_a?(String)
        _pre
      end
    end

    def root?
      !root.nil?
    end

    def panes?
      panes.any?
    end

    def tmux_window_target
      "#{project.name}:#{index + project.base_index}"
    end

    def tmux_pre_window_command
      return unless project.pre_window

      "#{project.tmux} send-keys -t #{tmux_window_target} #{project.pre_window.shellescape} C-m"
    end

    def tmux_window_command_prefix
      "#{project.tmux} send-keys -t #{project.name}:#{index + project.base_index}"
    end

    def tmux_window_name_option
      name ? "-n #{name}" : ""
    end

    def tmux_new_window_command
      path = root? ? "#{Tmuxinator::Config.default_path_option} #{root}" : nil
      "#{project.tmux} new-window #{path} -k -t #{tmux_window_target} #{tmux_window_name_option}"
    end

    def tmux_tiled_layout_command
      "#{project.tmux} select-layout -t #{tmux_window_target} tiled"
    end

    def tmux_focus_pane_command
      "#{project.tmux} select-pane -t #{focused_pane}"
    end

    def tmux_synchronize_panes
      "#{project.tmux} set-window-option -t #{tmux_window_target} synchronize-panes on"
    end

    def tmux_layout_command
      "#{project.tmux} select-layout -t #{tmux_window_target} #{layout}"
    end

    def synchronize_before?
      [true, "before"].include?(synchronize)
    end

    def synchronize_after?
      synchronize == "after"
    end

    private

    def focused_pane
      "#{tmux_window_target}.#{tmux_pane_index}"
    end

    def tmux_pane_index
      # Adjust for tmux pane base index
      pane_index + project.pane_base_index
    end

    def pane_index
      focused_pane = yaml["focused_pane"]
      # Select the first pane if the user hasn't set focused_pane
      return 0 unless focused_pane

      # The user may provide the focused pane index.
      return focused_pane if integer?(focused_pane)

      # If no pane iwth the given name is found fall back to the first pane
      panes.index { |pane| pane.title == focused_pane } || 0
    end

    def integer?(str)
      !!Integer(str)
    rescue StandardError
      false
    end
  end
end
