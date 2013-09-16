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
  end
end
