module Tmuxinator
  module Hooks
    module_function

    def commands_from(hook_config)
      if hook_config.is_a?(Array)
        hook_config.join("; ")
      else
        hook_config
      end
    end
  end
end
