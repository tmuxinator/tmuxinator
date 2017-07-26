module Tmuxinator
  module TmuxValidator
    TMUX_IS_NOT_AVAILABLE_MESSAGE = <<-TMUX_IS_NOT_AVAILABLE
Please ensure tmux has been installed and is available on $PATH.
TMUX_IS_NOT_AVAILABLE

    def self.validate!
      raise TMUX_IS_NOT_AVAILABLE_MESSAGE if tmux_is_not_available
    end

    def self.tmux_is_not_available
      !Tmuxinator::Config::installed?
    end
  end
end
