# frozen_string_literal: true

require "spec_helper"

shared_examples_for "a project hook" do
  let(:project) { FactoryBot.build(:project) }

  it "calls Hooks.commands_from" do
    expect(Tmuxinator::Hooks).to receive(:commands_from).
      with(kind_of(Tmuxinator::Project), hook_name).once
    project.send("hook_#{hook_name}")
  end

  context "hook value is string" do
    before { project.yaml[hook_name] = "echo 'on hook'" }

    it "returns the string" do
      expect(project.send("hook_#{hook_name}")).to eq("echo 'on hook'")
    end
  end

  context "hook value is Array" do
    before do
      project.yaml[hook_name] = [
        "echo 'on hook'",
        "echo 'another command here'"
      ]
    end

    it "joins array using ;" do
      expect(project.send("hook_#{hook_name}")).
        to eq("echo 'on hook'; echo 'another command here'")
    end
  end
end

describe Tmuxinator::Hooks::Project do
  let(:project) { FactoryBot.build(:project) }

  describe "#hook_on_project_start" do
    it_should_behave_like "a project hook" do
      let(:hook_name) { "on_project_start" }
    end
  end
  describe "#hook_on_project_first_start" do
    it_should_behave_like "a project hook" do
      let(:hook_name) { "on_project_first_start" }
    end
  end
  describe "#hook_on_project_restart" do
    it_should_behave_like "a project hook" do
      let(:hook_name) { "on_project_restart" }
    end
  end
  describe "#hook_on_project_exit" do
    it_should_behave_like "a project hook" do
      let(:hook_name) { "on_project_exit" }
    end
  end
  describe "#hook_on_project_stop" do
    it_should_behave_like "a project hook" do
      let(:hook_name) { "on_project_stop" }
    end
  end
end
