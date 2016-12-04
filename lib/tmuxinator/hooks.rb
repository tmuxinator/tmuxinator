module Tmuxinator
  module Hooks
    def hook_on_reattach
      reattach_config = yaml["on_reattach"]
      if reattach_config.is_a?(Array)
        reattach_config.join("; ")
      else
        reattach_config
      end
    end

    def hook_on_stop
      stop_config = yaml["on_stop"]
      if stop_config.is_a?(Array)
        stop_config.join("; ")
      else
        stop_config
      end
    end
  end
end
