module Tmuxinator
  module Helper
    
    def exit!(msg)
      puts msg
      Kernel.exit(1)
    end
    
    def confirm!(msg)
      puts msg
      if %w(yes Yes YES y).include?(STDIN.gets.chop)
        yield
      else
        exit! "Aborting."
      end
    end
    
  end
end