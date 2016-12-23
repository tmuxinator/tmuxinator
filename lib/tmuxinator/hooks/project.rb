module Tmuxinator
  module Hooks
    module Project
      module_function
      
      def hook_on_reattach
        reattach_config = yaml["on_reattach"]
        if reattach_config.is_a?(Array)
          reattach_config.join("; ")
        else
          reattach_config
        end
      end

      def hook_on_detach
        detach_config = yaml["on_detach"]
        if detach_config.is_a?(Array)
          detach_config.join("; ")
        else
          detach_config
        end
      end

      def hook_on_start
        start_config = yaml["on_start"]
        if start_config.is_a?(Array)
          start_config.join("; ")
        else
          start_config
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
end
