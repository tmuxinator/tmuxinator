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
      build_panes(yaml["panes"]) || []
    end

    def _hashed?
      @yaml.is_a?(Hash)
    end

    def yaml
      _hashed? ? @yaml : {}
    end

    def layout
      yaml["layout"] ? yaml["layout"].shellescape : nil
    end

    def synchronize
      yaml["synchronize"] || false
    end

    def root
      _yaml_root || _project_root
    end

    def _yaml_root
      File.expand_path(yaml["root"]).shellescape if yaml["root"]
    end

    def _project_root
      project.root if project.root?
    end

    def build_panes(panes_yml)
      return if panes_yml.nil?

      Array(panes_yml).map.with_index do |pane_yml, index|
        commands =  case pane_yml
                    when Hash
                      pane_yml.values.first
                    when Array
                      pane_yml
                    else
                      pane_yml
                    end

        Tmuxinator::Pane.new(index, project, self, *commands)
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
      "#{project.tmux} new-window #{path} -t #{tmux_window_target} #{tmux_window_name_option}"
    end

    def tmux_tiled_layout_command
      "#{project.tmux} select-layout -t #{tmux_window_target} tiled"
    end

    def tmux_synchronize_panes
      "#{project.tmux} set-window-option -t #{tmux_window_target} synchronize-panes on"
    end

    def tmux_layout_command
      "#{project.tmux} select-layout -t #{tmux_window_target} #{layout}"
    end

    def tmux_select_first_pane
      "#{project.tmux} select-pane -t #{tmux_window_target}.#{panes.first.index + project.pane_base_index}"
    end

    def synchronize_before?
      synchronize == true || synchronize == "before"
    end

    def synchronize_after?
      synchronize == "after"
    end
  end
end
