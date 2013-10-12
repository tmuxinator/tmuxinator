module Tmuxinator
  module WemuxSupport
    def wemux?
      yaml["tmux_command"] == "wemux"
    end

    def load_wemux_overrides
      self.instance_eval do
        def render
          template = File.read(Tmuxinator::Config.wemux_template)
          Erubis::Eruby.new(template).result(binding)
        end

        def name
          "wemux"
        end

        def tmux
          "wemux"
        end
      end
    end
  end
end
