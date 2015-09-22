def yaml_load(file)
  YAML.load(File.read(File.expand_path(file)))
end
FactoryGirl.define do
  factory :project, class: Tmuxinator::Project do
    transient do
      file { yaml_load("spec/fixtures/sample.yml") }
    end

    initialize_with { Tmuxinator::Project.new(file) }
  end

  factory :project_with_force_attach, class: Tmuxinator::Project do
    transient do
      file { yaml_load("spec/fixtures/detach.yml") }
    end

    initialize_with { Tmuxinator::Project.new(file, force_attach: true) }
  end

  factory :project_with_force_detach, class: Tmuxinator::Project do
    transient do
      file { yaml_load("spec/fixtures/detach.yml") }
    end
    initialize_with { Tmuxinator::Project.new(file, force_detach: true) }
  end

  factory :project_with_custom_name, class: Tmuxinator::Project do
    transient do
      file { yaml_load("spec/fixtures/sample.yml") }
    end

    initialize_with { Tmuxinator::Project.new(file, custom_name: "custom") }
  end

  factory :project_with_number_as_name, class: Tmuxinator::Project do
    transient do
      file { yaml_load("spec/fixtures/sample_number_as_name.yml") }
    end

    initialize_with { Tmuxinator::Project.new(file) }
  end

  factory :project_with_deprecations, class: Tmuxinator::Project do
    transient do
      file { yaml_load("spec/fixtures/sample.deprecations.yml") }
    end

    initialize_with { Tmuxinator::Project.new(file) }
  end

  factory :wemux_project, class: Tmuxinator::Project do
    transient do
      file { yaml_load("spec/fixtures/sample_wemux.yml") }
    end

    initialize_with { Tmuxinator::Project.new(file) }
  end

  factory :noname_project, class: Tmuxinator::Project do
    transient do
      file { yaml_load("spec/fixtures/noname.yml") }
    end

    initialize_with { Tmuxinator::Project.new(file) }
  end

  factory :nowindows_project, class: Tmuxinator::Project do
    transient do
      file { yaml_load("spec/fixtures/nowindows.yml") }
    end

    initialize_with { Tmuxinator::Project.new(file) }
  end

  factory :nameless_window_project, class: Tmuxinator::Project do
    transient do
      file { yaml_load("spec/fixtures/nameless_window.yml") }
    end

    initialize_with { Tmuxinator::Project.new(file) }
  end
end
