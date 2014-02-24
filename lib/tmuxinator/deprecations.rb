module Tmuxinator
  module Deprecations
    def rvm?
      yaml["rvm"]
    end

    def rbenv?
      yaml["rbenv"]
    end

    def pre_tab?
      yaml["pre_tab"]
    end

    def cli_args?
      yaml["cli_args"]
    end
  end
end
