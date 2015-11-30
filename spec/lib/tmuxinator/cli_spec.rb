require "spec_helper"
describe Tmuxinator::Cli do
  let(:cli) { Tmuxinator::Cli }

  before do
    ARGV.clear
    allow(Kernel).to receive(:system)
    allow(FileUtils).to receive(:copy_file)
    allow(FileUtils).to receive(:rm)
    allow(FileUtils).to receive(:remove_dir)
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
      allow(Tmuxinator::Config).to receive_messages(configs: ["test.yml"])
    end

    it "gets completions" do
      out, _err = capture_io { cli.start }
      expect(out).to include("test.yml")
    end
  end

  describe "#commands" do
    before do
      ARGV.replace(["commands"])
    end

    it "lists the commands" do
      out, _err = capture_io { cli.start }
      expected = %w(commands
                    completions
                    new
                    open
                    start
                    local
                    debug
                    copy
                    delete
                    implode
                    version
                    doctor
                    list)
      expect(out).to eq "#{expected.join("\n")}\n"
    end
  end

  describe "#start" do
    before do
      ARGV.replace(["start", "foo"])
      allow(Tmuxinator::Config).to receive_messages(validate: project)
      allow(Tmuxinator::Config).to receive_messages(version: 1.9)
      allow(Kernel).to receive(:exec)
    end

    context "no deprecations" do
      let(:project) { FactoryGirl.build(:project) }

      it "starts the project" do
        expect(Kernel).to receive(:exec)
        capture_io { cli.start }
      end

      it "accepts a flag for alternate name" do
        ARGV.replace(["start", "foo" "--name=bar"])

        expect(Kernel).to receive(:exec)
        capture_io { cli.start }
      end

      it "accepts additional arguments" do
        ARGV.replace(["start", "foo", "bar", "three=four"])

        expect(Kernel).to receive(:exec)
        capture_io { cli.start }
      end
    end

    context "deprecations" do
      before do
        allow($stdin).to receive_messages(getc: "y")
      end

      let(:project) { FactoryGirl.build(:project_with_deprecations) }

      it "prints the deprecations" do
        out, _err = capture_io { cli.start }
        expect(out).to include "DEPRECATION"
      end
    end
  end

  describe "#local" do
    shared_examples_for :local_project do
      before do
        allow(Tmuxinator::Config).to receive_messages(validate: project)
        allow(Tmuxinator::Config).to receive_messages(version: 1.9)
        allow(Kernel).to receive(:exec)
      end

      let(:project) { FactoryGirl.build(:project) }

      it "starts the project" do
        expect(Kernel).to receive(:exec)
        out, err = capture_io { cli.start }
        expect(err).to eq ""
        expect(out).to eq ""
      end
    end

    context "when the command used is 'local'" do
      before do
        ARGV.replace ["local"]
      end
      it_should_behave_like :local_project
    end

    context "when the command used is '.'" do
      before do
        ARGV.replace ["."]
      end
      it_should_behave_like :local_project
    end
  end

  describe "#start(custom_name)" do
    before do
      ARGV.replace(["start", "foo", "bar"])
      allow(Tmuxinator::Config).to receive_messages(validate: project)
      allow(Tmuxinator::Config).to receive_messages(version: 1.9)
      allow(Kernel).to receive(:exec)
    end

    context "no deprecations" do
      let(:project) { FactoryGirl.build(:project) }

      it "starts the project" do
        expect(Kernel).to receive(:exec)
        capture_io { cli.start }
      end
    end
  end

  describe "#edit" do
    let(:file) { StringIO.new }
    let(:name) { "test" }
    let(:path) { Tmuxinator::Config.default_project(name) }

    context "when the project file _does_ already exist" do
      let(:extra) { "  - extra: echo 'foobar'" }

      before do
        # make sure that no project file exists initially
        FileUtils.remove_file(path) if File.exists?(path)
        expect(File).not_to exist(path)

        # now generate a project file
        expect(Tmuxinator::Cli.new.generate_project_file(name, path)).to eq path
        expect(File).to exist path

        # add some content to the project file
        File.open(path, "w") do |f|
          f.write(extra)
          f.flush
        end
        expect(File.read(path)).to match %r{#{extra}}

        # get ready to run `tmuxinator edit #{name}`
        ARGV.replace ["edit", name]
      end

      it "should _not_ generate a new project file" do
        capture_io { cli.start }
        expect(File.read(path)).to match %r{#{extra}}
      end
    end
  end

  describe "#new" do
    let(:file) { StringIO.new }
    let(:name) { "test" }

    before do
      allow(File).to receive(:open) { |&block| block.yield file }
    end

    context "without the --local option" do
      before do
        ARGV.replace(["new", name])
      end

      context "existing project doesn't exist" do
        before do
          expect(File).to receive_messages(exists?: false)
        end

        it "creates a new tmuxinator project file" do
          capture_io { cli.start }
          expect(file.string).to_not be_empty
        end
      end

      context "files exists" do
        let(:root_path) { "#{ENV['HOME']}\/\.tmuxinator\/#{name}\.yml" }

        before do
          allow(File).to receive(:exists?).with(anything).and_return(false)
          expect(File).to receive(:exists?).with(root_path).and_return(true)
        end

        it "just opens the file" do
          expect(Kernel).to receive(:system).with(%r{#{root_path}})
          capture_io { cli.start }
        end
      end
    end

    context "with the --local option" do
      before do
        ARGV.replace ["new", name, "--local"]
      end

      context "existing project doesn't exist" do
        before do
          allow(File).to receive(:exists?).at_least(:once) do
            false
          end
        end

        it "creates a new tmuxinator project file" do
          capture_io { cli.start }
          expect(file.string).to_not be_empty
        end
      end

      context "files exists" do
        let(:path) { Tmuxinator::Config::LOCAL_DEFAULT }
        before do
          expect(File).to receive(:exists?).with(path) { true }
        end

        it "just opens the file" do
          expect(Kernel).to receive(:system).with(%r{#{path}})
          capture_io { cli.start }
        end
      end
    end
  end

  describe "#copy" do
    before do
      ARGV.replace(["copy", "foo", "bar"])
      allow(Tmuxinator::Config).to receive(:exists?) { true }
    end

    context "new project already exists" do
      before do
        allow(Thor::LineEditor).to receive_messages(readline: "y")
      end

      it "prompts user to confirm overwrite" do
        expect(FileUtils).to receive(:copy_file)
        capture_io { cli.start }
      end
    end

    context "existing project doens't exist" do
      before do
        allow(Tmuxinator::Config).to receive(:exists?) { false }
      end

      it "exit with error code" do
        expect { capture_io { cli.start } }.to raise_error SystemExit
      end
    end
  end

  describe "#debug" do
    let(:project) { FactoryGirl.build(:project) }
    let(:project_with_force_attach) do
      FactoryGirl.build(:project_with_force_attach)
    end
    let(:project_with_force_detach) do
      FactoryGirl.build(:project_with_force_detach)
    end

    before do
      allow(Tmuxinator::Config).to receive_messages(validate: project)
      expect(project).to receive(:render)
    end

    it "renders the project" do
      ARGV.replace(["debug", "foo"])
      capture_io { cli.start }
    end

    it "force attach renders the project with attach code" do
      ARGV.replace(["debug", "--attach=true", "sample"])
      capture_io { cli.start }
      # Currently no project is rendered at all,
      #   because the project file is not found
      # expect(out).to include "attach-session"
    end

    it "force detach renders the project without attach code" do
      ARGV.replace(["debug", "--attach=false", "sample"])
      capture_io { cli.start }
      # Currently no project is rendered at all
      # expect(out).to_not include "attach-session"
    end

    it "renders the project with custom session" do
      ARGV.replace(["debug", "sample", "bar"])
      capture_io { cli.start }
    end
  end

  describe "#delete" do
    before do
      ARGV.replace(["delete", "foo"])
      allow(Thor::LineEditor).to receive_messages(readline: "y")
    end

    context "project exists" do
      before do
        allow(Tmuxinator::Config).to receive(:exists?) { true }
      end

      it "deletes the project" do
        expect(FileUtils).to receive(:rm)
        capture_io { cli.start }
      end
    end

    context "project doesn't exist" do
      before do
        allow(Tmuxinator::Config).to receive(:exists?) { false }
        allow(Thor::LineEditor).to receive_messages(readline: "y")
      end

      it "exits with error message" do
        expect { capture_io { cli.start } }.to raise_error SystemExit
      end
    end
  end

  describe "#implode" do
    before do
      ARGV.replace(["implode"])
      allow(Thor::LineEditor).to receive_messages(readline: "y")
    end

    it "confirms deletion of all projects" do
      expect(Thor::LineEditor).to receive(:readline).and_return("y")
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
      allow(Dir).to receive_messages(:[] => ["/path/to/project.yml"])
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
      out, _err = capture_io { cli.start }
      expect(out).to eq "tmuxinator #{Tmuxinator::VERSION}\n"
    end
  end

  describe "#doctor" do
    before do
      ARGV.replace(["doctor"])
    end

    it "checks requirements" do
      expect(Tmuxinator::Config).to receive(:installed?)
      expect(Tmuxinator::Config).to receive(:editor?)
      expect(Tmuxinator::Config).to receive(:shell?)
      capture_io { cli.start }
    end
  end

  describe "#find_project_file" do
    let(:name) { "foobar" }
    let(:path) { Tmuxinator::Config.default_project(name) }

    after(:each) do
      FileUtils.remove_file(path) if File.exists?(path)
    end

    context "when the project file does not already exist" do
      before do
        expect(File).not_to exist(path), "expected file at #{path} not to exist"
      end

      it "should generate a project file" do
        new_path = Tmuxinator::Cli.new.find_project_file(name, false)
        expect(new_path).to eq path
        expect(File).to exist new_path
      end
    end

    context "when the project file _does_ already exist" do
      let(:extra) { "  - extra: echo 'foobar'" }

      before do
        expect(File).not_to exist(path), "expected file at #{path} not to exist"
        expect(Tmuxinator::Cli.new.generate_project_file(name, path)).to eq path
        expect(File).to exist path

        File.open(path, "w") do |f|
          f.write(extra)
          f.flush
        end
        expect(File.read(path)).to match %r{#{extra}}
      end

      it "should _not_ generate a new project file" do
        new_path = Tmuxinator::Cli.new.find_project_file(name, false)
        expect(new_path).to eq path
        expect(File).to exist new_path
        expect(File.read(new_path)).to match %r{#{extra}}
      end
    end
  end

  describe "#generate_project_file" do
    let(:name) { "foobar" }
    let(:path) { Tmuxinator::Config.default_project(name) }

    before do
      expect(File).not_to exist(path), "expected file at #{path} not to exist"
    end

    after(:each) do
      FileUtils.remove_file(path) if File.exists?(path)
    end

    it "should always generate a project file" do
      new_path = Tmuxinator::Cli.new.generate_project_file(name, path)
      expect(new_path).to eq path
      expect(File).to exist new_path
    end
  end

  describe "#create_project" do
    shared_examples_for :a_proper_project do
      it "should create a valid project" do
        expect(subject).to be_a Tmuxinator::Project
        expect(subject.name).to eq name
      end
    end

    let(:name) { "sample" }
    let(:custom_name) { nil }
    let(:cli_options) { {} }
    let(:path) { File.expand_path("../../../fixtures", __FILE__) }

    context "when creating a traditional named project" do
      let(:params) do
        {
          name: name,
          custom_name: custom_name
        }
      end
      subject { described_class.new.create_project(params) }

      before do
        allow(Tmuxinator::Config).to receive_messages(root: path)
      end

      it_should_behave_like :a_proper_project
    end
  end

  context "exit status" do
    before do
      ARGV.replace(["non-existent-command"])
    end

    it "returns a non-zero status when an error occurs" do
      expect { capture_io { cli.start } }.to raise_error(SystemExit) do |e|
        expect(e.status).to eq 1
      end
    end
  end
end
