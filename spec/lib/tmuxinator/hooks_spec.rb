# frozen_string_literal: true

require "spec_helper"

describe Tmuxinator::Hooks do
  describe "#commands_from" do
    let(:project) { FactoryBot.build(:project) }
    let(:hook_name) { "generic_hook" }

    context "config value is string" do
      before { project.yaml[hook_name] = "echo 'on hook'" }

      it "returns the string" do
        expect(subject.commands_from(project, hook_name)).
          to eq("echo 'on hook'")
      end
    end

    context "config value is Array" do
      before do
        project.yaml[hook_name] = [
          "echo 'on hook'",
          "echo 'another command here'"
        ]
      end

      it "joins array using ;" do
        expect(subject.commands_from(project, hook_name)).
          to eq("echo 'on hook'; echo 'another command here'")
      end
    end
  end
end
