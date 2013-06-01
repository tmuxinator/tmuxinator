require "spec_helper"

describe Tmuxinator::Project do
  let(:yml) do
    StringIO.new("project_name: Test\nproject_root: ~/code\ntabs:\n  - editor:\n  - shell:")
  end
  let(:project) { Tmuxinator::Project.new(yml) }

  describe "#initialize" do
    context "valid yaml" do
      it "creates an instance" do
        expect(project).to be_a(Tmuxinator::Project)
      end
    end

    context "invalid yaml" do
      let(:yml) { StringIO.new("key:\n\nkey") }

      it "raises an error" do
        expect { capture_io { Tmuxinator::Project.new(yml) } }.to raise_error SystemExit
      end
    end
  end

  describe "#tabs" do
    it "gets the list of tabs" do
      expect(project.tabs).to_not be_empty
    end
  end

  describe "#root" do
    it "gets the project_root" do
      expect(project.root).to eq "~/code"
    end
  end

  describe "#name" do
    it "gets the project name" do
      expect(project.name).to eq "Test"
    end
  end

  describe "#tabs?" do
    context "tabs are present" do
      it "returns true" do
        expect(project.tabs?).to be_true
      end
    end
  end

  describe "#root?" do
    context "root are present" do
      it "returns true" do
        expect(project.root?).to be_true
      end
    end
  end
end
