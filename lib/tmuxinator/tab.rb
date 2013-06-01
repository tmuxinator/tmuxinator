module Tmuxinator
  class Tab
    attr_reader :name, :panes, :layout, :pre, :command

    def initialize(tab_yaml)
      @name = tab_yaml.keys.first.present? ? tab_yaml.keys.first.shellescape : nil
      @panes = []
      @layout = nil
      @pre = nil
      @command = nil

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
        pane_yml.map do |pane_cmd|
          Tmuxinator::Pane.new(pane_cmd)
        end
      else
        Tmuxinator::Pane.new(pane_yml)
      end
    end

    def panes?
      panes.any?
    end
  end
end
