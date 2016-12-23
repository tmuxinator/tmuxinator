module Tmuxinator
  module Hooks
    module Project
      module_function

      # Commands specified in this hook run when "tmuxinator start project"
      # command is issued
      def hook_on_project_start
        # this method can only be used from inside Tmuxinator::Project
        Tmuxinator::Hooks.commands_from self, "on_project_start"
      end

      # Commands specified in this hook run when "tmuxinator start project"
      # command is issued and there is no tmux session available named "project"
      def hook_on_project_first_start
        # this method can only be used from inside Tmuxinator::Project
        Tmuxinator::Hooks.commands_from self, "on_project_first_start"
      end

      # Commands specified in this hook run when "tmuxinator start project"
      # command is issued and there is no tmux session available named "project"
      def hook_on_project_restart
        # this method can only be used from inside Tmuxinator::Project
        Tmuxinator::Hooks.commands_from self, "on_project_restart"
      end

      # Commands specified in this hook run when you exit from a project ( aka
      # detach from a tmux session )
      def hook_on_project_exit
        # this method can only be used from inside Tmuxinator::Project
        Tmuxinator::Hooks.commands_from self, "on_project_exit"
      end

      # Command specified in this hook run when "tmuxinator stop project"
      # command is issued
      def hook_on_project_stop
        # this method can only be used from inside Tmuxinator::Project
        Tmuxinator::Hooks.commands_from self, "on_project_stop"
      end
    end # End Project
  end # End Hooks
end # End Tmuxinator
