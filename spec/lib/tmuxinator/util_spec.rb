require "spec_helper"

describe Tmuxinator::Util do
  let(:util) { Object.new.extend(Tmuxinator::Util) }

  describe "#flatten_command" do
    it "flattens and joins an array" do
      command = [
        "command 1",
        "",
        "command 2",
      ]
      expect(util.flatten_command(command)).to eq("command 1 && command 2")
    end

    it "passes through a string" do
      command = "command 1"
      expect(util.flatten_command(command)).to eq("command 1")
    end
  end
end
