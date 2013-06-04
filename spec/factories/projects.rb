FactoryGirl.define do
  factory :project, :class => Tmuxinator::Project do
    ignore do
      file { YAML.load(File.read("#{File.expand_path("spec/fixtures/sample.yml")}")) }
    end

    initialize_with { Tmuxinator::Project.new(file) }
  end
end
