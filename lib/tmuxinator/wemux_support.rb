module Tmuxinator
  module WemuxSupport
    def wemux?
      yaml["tmux_command"] == "wemux"
    end

    def load_wemux_overrides
      class_eval do
        define_method :render do
          template = File.read(Tmuxinator::Config.wemux_template)
          Erubis::Eruby.new(template).result(binding)
        end

        define_method :name do
          "wemux"
        end

        define_method :tmux do
          "wemux"
        end
      end
    end
  end
end
