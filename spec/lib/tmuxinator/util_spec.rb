require "spec_helper"

describe Tmuxinator::Util do
  let(:util) { Object.new.extend(Tmuxinator::Util) }

  describe "#flatten_command" do
    context "commands are an array" do
      let(:command) { ["command 1", "", "command 2"] }

      it "flattens and joins into one command" do
        expect(util.flatten_command(command)).to eq("command 1 && command 2")
      end
    end

    context "command is a string" do
      let(:command) { "command 1" }

      it "passes through a string" do
        expect(util.flatten_command(command)).to eq("command 1")
      end
    end
  end
end
