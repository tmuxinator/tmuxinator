module Tmuxinator
  module Hooks
    module Project
      module_function

      def hook_on_reattach
        Tmuxinator::Hooks.commands_from yaml["on_reattach"]
      end

      def hook_on_detach
        Tmuxinator::Hooks.commands_from yaml["on_detach"]
      end

      def hook_on_start
        Tmuxinator::Hooks.commands_from yaml["on_start"]
      end

      def hook_on_stop
        Tmuxinator::Hooks.commands_from yaml["on_stop"]
      end
    end
  end
end
