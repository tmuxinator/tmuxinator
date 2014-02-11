FactoryGirl.define do
  factory :project, :class => Tmuxinator::Project do

    config_path = File.expand_path("spec/fixtures/sample.yml")
    ignore do
      file { YAML.load(File.read(config_path)) }
    end

    initialize_with { Tmuxinator::Project.new(file, config_path: config_path) }
  end

  factory :project_with_deprecations, :class => Tmuxinator::Project do
    ignore do
      file { YAML.load(File.read("#{File.expand_path("spec/fixtures/sample.deprecations.yml")}")) }
    end

    initialize_with { Tmuxinator::Project.new(file) }
  end

  factory :project_with_context, :class => Tmuxinator::Project do

    config_path = File.expand_path("spec/fixtures/sample.context.yml")
    ignore do
      file { YAML.load(File.read(config_path)) }
    end

    initialize_with { Tmuxinator::Project.new(file, config_path: config_path) }
  end

end
