require "spec_helper"
describe Tmuxinator::Cli do
  let(:cli) { Tmuxinator::Cli }

  before do
    $0 = "vmc"
    ARGV.clear
    Kernel.stub(:system)
    FileUtils.stub(:copy_file)
    FileUtils.stub(:rm)
    FileUtils.stub(:remove_dir)
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
        Tmuxinator::Config.stub(:exists? => false)
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
    let(:project) { FactoryGirl.build(:project) }

    before do
      Tmuxinator::Config.stub(:exists? => true)
      Tmuxinator::Project.stub(:new => project)
      ARGV.replace(["start", "temp"])
    end

    it "starts a tmuxinator session" do
      Kernel.should_receive(:exec)
      capture_io { cli.start }
    end
  end

  describe "#copy" do
    before do
      ARGV.replace(["copy", "foo", "bar"])
      Tmuxinator::Config.stub(:exists?) { true }
    end

    context "new project already exists" do
      before do
        $stdin.should_receive(:gets).and_return("y")
      end

      it "prompts user to confirm overwrite" do
        FileUtils.should_receive(:rm)
        capture_io { cli.start }
      end

      it "copies the config" do
        FileUtils.should_receive(:copy_file)
        capture_io { cli.start }
      end
    end

    context "existing project doens't exist" do
      before do
        Tmuxinator::Config.stub(:exists?) { false }
      end

      it "exit with error code" do
        expect { capture_io { cli.start } }.to raise_error SystemExit
      end
    end
  end

  describe "#delete" do
    before do
      ARGV.replace(["delete", "foo"])
    end

    context "project exists" do
      before do
        Tmuxinator::Config.stub(:exists?) { true }
      end

      it "confirms deletion" do
        $stdin.should_receive(:gets).and_return("y")
        capture_io { cli.start }
      end

      it "deletes the project" do
        $stdin.should_receive(:gets).and_return("y")
        FileUtils.should_receive(:rm)
        capture_io { cli.start }
      end
    end

    context "project doesn't exist" do
      it "exits with error message" do
        expect { capture_io { cli.start } }.to raise_error SystemExit
      end
    end
  end

  describe "#implode" do
    before do
      ARGV.replace(["implode"])
    end

    it "confirms deletion of all projects" do
      $stdin.should_receive(:gets).and_return("y")
      capture_io { cli.start }
    end

    it "deletes all projects" do
      $stdin.should_receive(:gets).and_return("y")
      FileUtils.should_receive(:remove_dir)
      capture_io { cli.start }
    end
  end

  describe "#list" do
    before do
      ARGV.replace(["list"])
      Dir.stub(:[] => ["/path/to/project.yml"])
    end

    it "lists all projects" do
      expect { capture_io { cli.start } }.to_not raise_error
    end
  end

  describe "#version" do
    before do
      ARGV.replace(["version"])
    end

    it "prints the current version" do
      out, _ = capture_io { cli.start }
      expect(out).to eq "tmuxinator #{Tmuxinator::VERSION}\n"
    end
  end

  describe "#doctor" do
    before do
      ARGV.replace(["doctor"])
    end

    it "checks requirements" do
      Tmuxinator::Config.should_receive(:installed?)
      Tmuxinator::Config.should_receive(:editor?)
      Tmuxinator::Config.should_receive(:shell?)
      capture_io { cli.start }
    end
  end
end
