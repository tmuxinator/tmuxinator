FactoryGirl.define do
  factory :project, :class => Tmuxinator::Project do
    ignore do
      file { YAML.load(File.read("#{File.expand_path("spec/fixtures/sample.yml")}")) }
    end

    initialize_with { Tmuxinator::Project.new(file) }
  end

  factory :project_with_deprecations, :class => Tmuxinator::Project do
    ignore do
      file { YAML.load(File.read("#{File.expand_path("spec/fixtures/sample.deprecations.yml")}")) }
    end

    initialize_with { Tmuxinator::Project.new(file) }
  end

  factory :project_with_erb, :class => Tmuxinator::Project do
    ignore do
      file { YAML.load(ERB.new(File.read("#{File.expand_path("spec/fixtures/sample.erb.yml")}")).result) }
    end

    initialize_with { Tmuxinator::Project.new(file) }
  end
end
