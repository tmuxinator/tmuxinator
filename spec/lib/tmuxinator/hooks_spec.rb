require "spec_helper"

shared_examples_for "a project hook" do
  let(:project) { FactoryGirl.build(:project) }

  context "hook value in yaml is string" do
    before { project.yaml["on_#{hook}"] = "echo 'on reattach'" }

    it "returns the string" do
      expect(project.send("hook_on_#{hook}")).to eq("echo 'on reattach'")
    end
  end

  context "hook value in yaml is Array" do
    before do
      project.yaml["on_#{hook}"] = [
        "echo 'on reattach'",
        "echo 'another command here'"
      ]
    end

    it "joins array using ;" do
      expect(project.send("hook_on_#{hook}")).
        to eq("echo 'on reattach'; echo 'another command here'")
    end
  end
end

describe Tmuxinator::Hooks do
  let(:project) { FactoryGirl.build(:project) }

  describe "#hook_on_reattach" do
    it_should_behave_like "a project hook" do
      let(:hook) { "reattach" }
    end
  end

  describe "#hook_on_stop" do
    it_should_behave_like "a project hook" do
      let(:hook) { "stop" }
    end
  end
end
