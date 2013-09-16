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

    def build_commands(command_yml)
      if command_yml.is_a?(Array)
        command_yml.map do |command|
          "#{command.shellescape} C-m" if command.present?
        end.compact
      elsif command_yml.present?
        ["#{command_yml.shellescape} C-m"]
      else
        []
      end
    end
  end
end
