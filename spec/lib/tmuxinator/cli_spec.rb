require "spec_helper"

describe Tmuxinator::Cli do
  let(:cli) { Tmuxinator::Cli }

  before { ARGV.replace([]) }

  context "no arguments" do
    it "runs without error" do
      out, err = capture_io { cli.start }
      expect(err).to be_empty
    end
  end

  describe "#start" do
    before do
      Kernel.stub(:exec)
    end

    context "no project provided" do
      before { ARGV.replace(["start"]) }

      it "displays an error message" do
        out, err = capture_io { cli.start }
        expect(err).to_not be_empty
      end
    end
  end

  describe "#new" do
    it "creates a new tmuxinator project file" do
      pending
    end
  end

  describe "#copy" do
  end
end
