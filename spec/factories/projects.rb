FactoryGirl.define do
  factory :project, :class => Tmuxinator::Project do
    ignore do
      file { File.open("#{File.dirname(__FILE__)}/../fixtures/sample.yml") }
    end

    initialize_with { Tmuxinator::Project.new(file) }
  end
end
