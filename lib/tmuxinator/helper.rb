require "thor"

module Tmuxinator
  module Helper
    include Thor::Actions

    def exit!(msg)
      say msg, :red
      Kernel.exit(1)
    end
  end
end
