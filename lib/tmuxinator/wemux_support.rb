module Tmuxinator
  module WemuxSupport
    COMMAND = "wemux".freeze

    def wemux?
      yaml["tmux_command"] == COMMAND
    end

    def load_wemux_overrides
      override_render!
      override_commands!
    end

    def override_render!
      class_eval do
        define_method :render do
          Tmuxinator::Project.render_template(
            Tmuxinator::Config.wemux_template,
            binding
          )
        end
      end
    end

    def override_commands!
      class_eval do
        %i[name tmux].each do |m|
          define_method(m) { COMMAND }
        end
      end
    end
  end
end
