module Tmuxinator
  module Deprecations
    def rvm?
      yaml["rvm"].present?
    end

    def rbenv?
      yaml["rbenv"].present?
    end

    def pre_tab?
      yaml["pre_tab"].present?
    end

    def cli_args?
      yaml["cli_args"].present?
    end
  end
end
