require "spec_helper"

describe Tmuxinator::Util do
  let(:util) { Object.new.extend(Tmuxinator::Util) }

  describe "#build_commands" do
    context "commands are an array" do
      let(:command) { ["command 1", "", "command 2"] }

      it "returns an array of commands" do
        expect(util.build_commands(command)).to eq(["command\\ 1 C-m", "command\\ 2 C-m"])
      end
    end

    context "command is a string" do
      let(:command) { "command 1" }

      it "passes through a string" do
        expect(util.build_commands(command)).to eq(["command\\ 1 C-m"])
      end
    end

    context "command is not present" do
      let(:command) { "" }

      it "returns an empty array" do
        expect(util.build_commands(command)).to be_empty
      end
    end
  end
end
