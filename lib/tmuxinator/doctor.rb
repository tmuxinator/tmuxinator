module Tmuxinator
  class Doctor
    class << self
      def editor?
        !ENV["EDITOR"].nil? && !ENV["EDITOR"].empty?
      end

      def installed?
        Kernel.system("type tmux > /dev/null")
      end

      def shell?
        !ENV["SHELL"].nil? && !ENV["SHELL"].empty?
      end
    end
  end
end
