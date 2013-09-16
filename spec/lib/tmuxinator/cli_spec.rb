require "spec_helper"
describe Tmuxinator::Cli do
  let(:cli) { Tmuxinator::Cli }

  before do
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

  describe "#completions" do
    before do
      ARGV.replace(["completions", "start"])
      Tmuxinator::Config.stub(:configs => ["test.yml"])
    end

    it "gets completions" do
      out, _ = capture_io { cli.start }
      expect(out).to include("test.yml")
    end
  end

  describe "#commands" do
    before do
      ARGV.replace(["commands"])
    end

    it "lists the commands" do
      out, _ = capture_io { cli.start }
      expect(out).to eq "#{%w(commands copy debug delete doctor help implode list start version).join("\n")}\n"
    end
  end

  describe "#start" do
    before do
      ARGV.replace(["start", "foo"])
      Tmuxinator::Config.stub(:validate => project)
      Kernel.stub(:exec)
    end

    context "no deprecations" do
      let(:project) { FactoryGirl.build(:project) }

      it "starts the project" do
        expect(Kernel).to receive(:exec)
        capture_io { cli.start }
      end
    end

    context "deprecations" do
      before do
        $stdin.stub(:getc => "y")
      end

      let(:project) { FactoryGirl.build(:project_with_deprecations) }

      it "prints the deprecations" do
        out, _ = capture_io { cli.start }
        expect(out).to include "DEPRECATION"
      end
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
        expect(Kernel).to receive(:system)
        capture_io { cli.start }
      end
    end
  end

  describe "#copy" do
    before do
      ARGV.replace(["copy", "foo", "bar"])
      Tmuxinator::Config.stub(:exists?) { true }
    end

    context "new project already exists" do
      before do
        $stdin.stub(:gets => "y")
      end

      it "prompts user to confirm overwrite" do
        expect(FileUtils).to receive(:rm)
        capture_io { cli.start }
      end

      it "copies the config" do
        expect(FileUtils).to receive(:copy_file)
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

  describe "#debug" do
    let(:project) { FactoryGirl.build(:project) }

    before do
      ARGV.replace(["debug", "foo"])
      Tmuxinator::Config.stub(:validate => project)
    end

    it "renders the project" do
      expect(project).to receive(:render)
      capture_io { cli.start }
    end
  end

  describe "#delete" do
    before do
      ARGV.replace(["delete", "foo"])
      $stdin.stub(:gets => "y")
    end

    context "project exists" do
      before do
        Tmuxinator::Config.stub(:exists?) { true }
      end

      it "confirms deletion" do
        capture_io { cli.start }
      end

      it "deletes the project" do
        expect(FileUtils).to receive(:rm)
        capture_io { cli.start }
      end
    end

    context "project doesn't exist" do
      before do
        $stdin.stub(:gets => "y")
      end

      it "exits with error message" do
        expect { capture_io { cli.start } }.to raise_error SystemExit
      end
    end
  end

  describe "#implode" do
    before do
      ARGV.replace(["implode"])
      $stdin.stub(:gets => "y")
    end

    it "confirms deletion of all projects" do
      expect($stdin).to receive(:gets).and_return("y")
      capture_io { cli.start }
    end

    it "deletes all projects" do
      expect(FileUtils).to receive(:remove_dir)
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
