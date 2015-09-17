module Tmuxinator
  module Deprecations
    def method_missing(name, *args, &block)
      {:rvm? => "rvm", :rbenv? => "rbenv", :pre_tab? => "pre_tab", :cli_args? => "cli_args"}.each do |key,value|
        if key == name
          return yaml[value]
        end
      end
    end
  end
end