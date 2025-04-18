# frozen_string_literal: true

module Tmuxinator
  module Util
    include Thor::Actions

    def exit!(msg)
      puts msg
      Kernel.exit(1)
    end

    def yes_no(condition)
      condition ? say("Yes", :green) : say("No", :red)
    end

    def current_session_name
      `[[ -n "${TMUX+set}" ]] && tmux display-message -p "#S"`.strip
    end
  end
end
