module Tmuxinator
  module Hooks
    module_function

    def commands_from(project, hook_name)
      hook_config = project.yaml[hook_name]
      if hook_config.is_a?(Array)
        hook_config.join("; ")
      else
        hook_config
      end
    end
  end
end
