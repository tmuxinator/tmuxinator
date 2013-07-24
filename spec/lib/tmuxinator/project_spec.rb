require "spec_helper"

describe Tmuxinator::Project do
  let(:project) { FactoryGirl.build(:project) }

  describe "#initialize" do
    context "valid yaml" do
      it "creates an instance" do
        expect(project).to be_a(Tmuxinator::Project)
      end
    end
  end

  describe "#render" do
    it "renders the tmux config" do
      expect(project.render).to_not be_empty
    end
  end

  describe "#windows" do
    it "gets the list of windows" do
      expect(project.windows).to_not be_empty
    end
  end

  describe "#root" do
    it "gets the project_root" do
      expect(project.root).to eq "~/test"
    end
  end

  describe "#name" do
    it "gets the project name" do
      expect(project.name).to eq "sample"
    end
  end

  describe "#windows?" do
    context "windows are present" do
      it "returns true" do
        expect(project.windows?).to be_true
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
