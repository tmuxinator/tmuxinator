def yaml_load(file)
  YAML.load(File.read(File.expand_path(file)))
end
FactoryGirl.define do
  factory :project, class: Tmuxinator::Project::Tmux do
    transient do
      file { yaml_load("spec/fixtures/sample.yml") }
    end

    initialize_with { Tmuxinator::Project::Tmux.new(file) }
  end

  factory :project_with_force_attach, class: Tmuxinator::Project::Tmux do
    transient do
      file { yaml_load("spec/fixtures/detach.yml") }
    end

    initialize_with { Tmuxinator::Project::Tmux.new(file, force_attach: true) }
  end

  factory :project_with_force_detach, class: Tmuxinator::Project::Tmux do
    transient do
      file { yaml_load("spec/fixtures/detach.yml") }
    end
    initialize_with { Tmuxinator::Project::Tmux.new(file, force_detach: true) }
  end

  factory :project_with_custom_name, class: Tmuxinator::Project::Tmux do
    transient do
      file { yaml_load("spec/fixtures/sample.yml") }
    end

    initialize_with do
      Tmuxinator::Project::Tmux.new(file, custom_name: "custom")
    end
  end

  factory :project_with_number_as_name, class: Tmuxinator::Project::Tmux do
    transient do
      file { yaml_load("spec/fixtures/sample_number_as_name.yml") }
    end

    initialize_with { Tmuxinator::Project::Tmux.new(file) }
  end

  factory(
    :project_with_literals_as_window_name,
    class: Tmuxinator::Project::Tmux
  ) do
    transient do
      file { yaml_load("spec/fixtures/sample_literals_as_window_name.yml") }
    end

    initialize_with { Tmuxinator::Project::Tmux.new(file) }
  end

  factory :project_with_deprecations, class: Tmuxinator::Project::Tmux do
    transient do
      file { yaml_load("spec/fixtures/sample.deprecations.yml") }
    end

    initialize_with { Tmuxinator::Project::Tmux.new(file) }
  end

  factory :wemux_project, class: Tmuxinator::Project::Wemux do
    transient do
      file { yaml_load("spec/fixtures/sample_wemux.yml") }
    end

    initialize_with { Tmuxinator::Project::Wemux .new(file) }
  end

  factory :noname_project, class: Tmuxinator::Project::Tmux do
    transient do
      file { yaml_load("spec/fixtures/noname.yml") }
    end

    initialize_with { Tmuxinator::Project::Tmux.new(file) }
  end

  factory :noroot_project, class: Tmuxinator::Project::Tmux do
    transient do
      file { yaml_load("spec/fixtures/noroot.yml") }
    end

    initialize_with { Tmuxinator::Project::Tmux.new(file) }
  end

  factory :nowindows_project, class: Tmuxinator::Project::Tmux do
    transient do
      file { yaml_load("spec/fixtures/nowindows.yml") }
    end

    initialize_with { Tmuxinator::Project::Tmux.new(file) }
  end

  factory :nameless_window_project, class: Tmuxinator::Project::Tmux do
    transient do
      file { yaml_load("spec/fixtures/nameless_window.yml") }
    end

    initialize_with { Tmuxinator::Project::Tmux.new(file) }
  end
end
