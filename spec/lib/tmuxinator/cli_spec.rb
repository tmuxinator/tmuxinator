require "spec_helper"

describe Tmuxinator::Cli do
  let(:cli) { Tmuxinator::Cli }

  before do
    ARGV.replace([])
    Kernel.stub(:system)
  end

  context "no arguments" do
    it "runs without error" do
      _, err = capture_io { cli.start }
      expect(err).to be_empty
    end
  end

  describe "#new" do
    let(:file) { StringIO.new }

    before do
      ARGV.replace(["new", "test"])
      File.stub(:open) { |&block| block.yield file }
    end

    context "existing project doesn't exist" do
      before do
        File.stub(:exists? => false)
      end

      it "creates a new tmuxinator project file" do
        capture_io { cli.start }
        expect(file.string).to_not be_empty
      end
    end

    context "files exists" do
      before do
        File.stub(:exists? => true)
      end

      it "just opens the file" do
        Kernel.should_receive(:system)
        capture_io { cli.start }
      end
    end
  end

  describe "#start" do
    before do
      Tmuxinator::ConfigWriter.stub_chain(:new, :render)
      ARGV.replace(["start", "temp"])
    end

    it "starts a tmuxinator session" do
      Kernel.should_receive(:exec)
      capture_io { cli.start }
    end
  end

  describe "#copy" do
    it "copies the config" do
      pending
    end

    context "new project already exists" do
      it "prompts user to confirm overwrite" do
        pending
      end
    end

    context "existing project doens't exist" do
      it "exit with error code" do
        pending
      end
    end
  end

  describe "#delete" do
    it "confirms deletion" do
      pending
    end

    it "deletes the project" do
      pending
    end
  end

  describe "#implode" do
    it "confirms deletion of all projects" do
      pending
    end

    it "deletes all projects" do
      pending
    end
  end

  describe "#list" do
    it "lists all projects" do
      pending
    end
  end

  describe "#version" do
    it "prints the current version" do
      pending
    end
  end

  describe "#doctor" do
    it "checks requirements" do
      pending
    end
  end
end
