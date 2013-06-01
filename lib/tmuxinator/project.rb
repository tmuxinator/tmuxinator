module Tmuxinator
  class Project
    include Tmuxinator::Helper

    attr_reader :yaml

    def initialize(file)
      begin
        @yaml = YAML.load(file.read)
      rescue
        exit!("Invalid YAML file format.")
      end
    end

    def tabs
      yaml["tabs"]
    end

    def root
      yaml["project_root"]
    end

    def name
      yaml["project_name"]
    end

    def tabs?
      tabs.any?
    end

    def root?
      root.present?
    end

    def name?
      name.present?
    end
  end
end
