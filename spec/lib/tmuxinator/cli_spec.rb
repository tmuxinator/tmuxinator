# frozen_string_literal: true

require "spec_helper"

describe Tmuxinator::Cli do
  shared_context :local_project_setup do
    let(:local_project_config) { ".tmuxinator.yml" }
    let(:content_fixture) { "../../fixtures/sample.yml" }
    let(:content_relpath) { File.join(File.dirname(__FILE__), content_fixture) }
    let(:content_path) { File.expand_path(content_relpath) }
    let(:content) { File.read(content_path) }
    let(:working_dir) { FileUtils.pwd }
    let(:local_project_relpath) { File.join(working_dir, local_project_config) }
    let(:local_project_path) { File.expand_path(local_project_relpath) }

    before do
      File.new(local_project_path, "w").tap do |f|
        f.write content
      end.close
      expect(File.exist?(local_project_path)).to be_truthy
      expect(File.read(local_project_path)).to eq content
    end

    after do
      File.delete(local_project_path)
    end
  end

  subject(:cli) { described_class }

  let(:fixtures_dir) { File.expand_path("../../fixtures", __dir__) }
  let(:project) { FactoryBot.build(:project) }
  let(:project_config) do
    File.join(fixtures_dir, "sample_with_project_config.yml")
  end

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

  context "base thor functionality" do
    shared_examples_for :base_thor_functionality do
      it "supports -v" do
        out, err = capture_io { cli.bootstrap(["-v"]) }
        expect(err).to eq ""
        expect(out).to include(Tmuxinator::VERSION)
      end

      it "supports help" do
        out, err = capture_io { cli.bootstrap(["help"]) }
        expect(err).to eq ""
        expect(out).to include("tmuxinator commands:")
      end
    end

    it_should_behave_like :base_thor_functionality

    context "with a local project config" do
      include_context :local_project_setup

      it_should_behave_like :base_thor_functionality
    end
  end

  describe "::bootstrap" do
    subject { cli.bootstrap(args) }
    let(:args) { [] }

    shared_examples_for :bootstrap_with_arguments do
      let(:args) { [arg1] }

      context "and the first arg is a tmuxinator command" do
        let(:arg1) { "list" }

        it "should call ::start" do
          expect(cli).to receive(:start).with(args)
          subject
        end
      end

      context "and the first arg is" do
        let(:arg1) { "sample" }

        context "a tmuxinator project name" do
          before do
            expect(Tmuxinator::Config).to \
              receive(:exist?).with(name: arg1) { true }
          end

          it "should call #start" do
            instance = instance_double(cli)
            expect(cli).to receive(:new).and_return(instance)
            expect(instance).to receive(:start).with(*args)
            subject
          end
        end

        context "a thor command" do
          context "(-v)" do
            let(:arg1) { "-v" }

            it "should call ::start" do
              expect(cli).to receive(:start).with(args)
              subject
            end
          end

          context "(help)" do
            let(:arg1) { "help" }

            it "should call ::start" do
              expect(cli).to receive(:start).with(args)
              subject
            end
          end
        end

        context "something else" do
          before do
            expect(Tmuxinator::Config).to \
              receive(:exist?).with(name: arg1) { false }
          end

          it "should call ::start" do
            expect(cli).to receive(:start).with(args)
            subject
          end
        end
      end
    end

    context "and there is a local project config" do
      include_context :local_project_setup

      context "when no args are supplied" do
        it "should call #local" do
          instance = instance_double(cli)
          expect(cli).to receive(:new).and_return(instance)
          expect(instance).to receive(:local)
          subject
        end
      end

      context "when one or more args are supplied" do
        it_should_behave_like :bootstrap_with_arguments
      end
    end

    context "and there is no local project config" do
      context "when no args are supplied" do
        it "should call ::start" do
          expect(cli).to receive(:start).with([])
          subject
        end
      end

      context "when one or more args are supplied" do
        it_should_behave_like :bootstrap_with_arguments
      end
    end
  end

  describe "#completions" do
    before do
      ARGV.replace(["completions", "start"])
      allow(Tmuxinator::Config).to receive_messages(configs: ["test.yml",
                                                              "foo.yml"])
    end

    it "gets completions" do
      out, _err = capture_io { cli.start }
      expect(out).to include("test.yml\nfoo.yml")
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
                    edit
                    open
                    start
                    stop
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

  shared_examples_for :unsupported_version_message do |*args|
    before do
      ARGV.replace([*args])
    end

    context "unsupported version" do
      before do
        allow($stdin).to receive_messages(getc: "y")
        allow(Tmuxinator::TmuxVersion).to receive(:supported?).and_return(false)
      end

      it "prints the warning" do
        out, _err = capture_io { cli.start }
        expect(out).to include "WARNING"
      end

      context "with --suppress-tmux-version-warning flag" do
        before do
          ARGV.replace([*args, "--suppress-tmux-version-warning"])
        end

        it "does not print the warning" do
          out, _err = capture_io { cli.start }
          expect(out).not_to include "WARNING"
        end
      end
    end

    context "supported version" do
      before do
        allow($stdin).to receive_messages(getc: "y")
        allow(Tmuxinator::TmuxVersion).to receive(:supported?).and_return(true)
      end

      it "does not print the warning" do
        out, _err = capture_io { cli.start }
        expect(out).not_to include "WARNING"
      end
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
      it "starts the project" do
        expect(Kernel).to receive(:exec)
        capture_io { cli.start }
      end

      it "accepts a flag for alternate name" do
        ARGV.replace(["start", "foo", "--name=bar"])

        expect(Kernel).to receive(:exec)
        capture_io { cli.start }
      end

      it "accepts a project config file flag" do
        ARGV.replace(["start", "foo", "--project-config=sample.yml"])

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

      let(:project) { FactoryBot.build(:project_with_deprecations) }

      it "prints the deprecations" do
        out, _err = capture_io { cli.start }
        expect(out).to include "DEPRECATION"
      end
    end

    include_examples :unsupported_version_message, :start, :foo
  end

  describe "#stop" do
    before do
      allow(Tmuxinator::Config).to receive_messages(validate: project)
      allow(Tmuxinator::Config).to receive_messages(version: 1.9)
      allow(Kernel).to receive(:exec)
    end

    context "with project name" do
      it "stops the project" do
        ARGV.replace(["stop", "foo"])
        expect(Kernel).to receive(:exec)
        out, err = capture_io { cli.start }
        expect(err).to eq ""
        expect(out).to eq ""
      end
    end

    context "without project name" do
      it "stops the project using .tmuxinator.yml" do
        ARGV.replace(["stop"])
        expect(Kernel).to receive(:exec)
        out, err = capture_io { cli.start }
        expect(err).to eq ""
        expect(out).to eq ""
      end
    end

    include_examples :unsupported_version_message, :stop, :foo
  end

  describe "#stop(with project config file)" do
    before do
      allow(Tmuxinator::Config).to receive(:validate).and_call_original
      allow(Tmuxinator::Config).to receive_messages(version: 1.9)
      allow(Kernel).to receive(:exec)
    end

    it "stops the project" do
      ARGV.replace(["stop", "--project-config=#{project_config}"])
      expect(Tmuxinator::Config).to receive_messages(validate: project)
      expect(Kernel).to receive(:exec)
      out, err = capture_io { cli.start }
      expect(err).to eq ""
      expect(out).to eq ""
    end

    it "does not stop the project if given a bogus project config file" do
      ARGV.replace(["stop", "--project-config=bogus.yml"])
      expect(Kernel).not_to receive(:exec)
      expect { capture_io { cli.start } }.to raise_error(SystemExit)
    end

    it "does not set the project name" do
      ARGV.replace(["stop", "--project-config=#{project_config}"])
      expect(Tmuxinator::Config).
        to(receive(:validate).
           with(hash_including(name: nil)))
      capture_io { cli.start }
    end

    it "does not set the project name even when set" do
      ARGV.replace(["stop", "bar", "--project-config=#{project_config}"])
      expect(Tmuxinator::Config).
        to(receive(:validate).
           with(hash_including(name: nil)))
      capture_io { cli.start }
    end
  end

  describe "#local" do
    before do
      allow(Tmuxinator::Config).to receive_messages(validate: project)
      allow(Tmuxinator::Config).to receive_messages(version: 1.9)
      allow(Kernel).to receive(:exec)
    end

    shared_examples_for :local_project do
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

    include_examples :unsupported_version_message, :local
  end

  describe "#start(custom_name)" do
    before do
      ARGV.replace(["start", "foo", "bar"])
      allow(Tmuxinator::Config).to receive_messages(validate: project)
      allow(Tmuxinator::Config).to receive_messages(version: 1.9)
      allow(Kernel).to receive(:exec)
    end

    context "no deprecations" do
      it "starts the project" do
        expect(Kernel).to receive(:exec)
        capture_io { cli.start }
      end
    end
  end

  describe "#start(with project config file)" do
    before do
      allow(Tmuxinator::Config).to receive(:validate).and_call_original
      allow(Tmuxinator::Config).to receive_messages(version: 1.9)
      allow(Kernel).to receive(:exec)
    end

    context "no deprecations" do
      it "starts the project if given a valid project config file" do
        ARGV.replace(["start", "--project-config=#{project_config}"])
        expect(Kernel).to receive(:exec)
        capture_io { cli.start }
      end

      it "does not start the project if given a bogus project config file" do
        ARGV.replace(["start", "--project-config=bogus.yml"])
        expect(Kernel).not_to receive(:exec)
        expect { capture_io { cli.start } }.to raise_error(SystemExit)
      end

      it "passes additional arguments through" do
        ARGV.replace(["start", "--project-config=#{project_config}", "extra"])
        expect(Tmuxinator::Config).
          to(receive(:validate).
             with(hash_including(args: array_including("extra"))))
        capture_io { cli.start }
      end

      it "does not set the project name" do
        ARGV.replace(["start", "--project-config=#{project_config}"])
        expect(Tmuxinator::Config).
          to(receive(:validate).
             with(hash_including(name: nil)))
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
        FileUtils.remove_file(path) if File.exist?(path)
        expect(File).not_to exist(path)

        # now generate a project file
        expect(described_class.new.generate_project_file(name, path)).to eq path
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
          expect(File).to receive_messages(exist?: false)
        end

        it "creates a new tmuxinator project file" do
          capture_io { cli.start }
          expect(file.string).to_not be_empty
        end
      end

      context "file exists" do
        let(:project_path) { Tmuxinator::Config.project(name).to_s }

        before do
          allow(File).to receive(:exist?).with(anything).and_return(false)
          expect(File).to receive(:exist?).with(project_path).and_return(true)
        end

        it "just opens the file" do
          expect(Kernel).to receive(:system).with(%r{#{project_path}})
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
          allow(File).to receive(:exist?).at_least(:once) do
            false
          end
        end

        it "creates a new tmuxinator project file" do
          capture_io { cli.start }
          expect(file.string).to_not be_empty
        end
      end

      context "file exists" do
        let(:path) { Tmuxinator::Config::LOCAL_DEFAULTS[0] }
        before do
          expect(File).to receive(:exist?).with(path) { true }
        end

        it "just opens the file" do
          expect(Kernel).to receive(:system).with(%r{#{path}})
          capture_io { cli.start }
        end
      end
    end

    # this command variant only works for tmux version 1.6 and up.
    context "from a session" do
      context "with tmux >= 1.6", if: Tmuxinator::Config.version >= 1.6 do
        before do
          # Necessary to make `Doctor.installed?` work in specs
          allow(Tmuxinator::Doctor).to receive(:installed?).and_return(true)
        end

        context "session exists" do
          before(:all) do
            # Can't add variables through `let` in `before :all`.
            @session = "for-testing-tmuxinator"
            # Pass the -d option, so that the session is not attached.
            Kernel.system "tmux new-session -d -s #{@session}"
          end

          before do
            ARGV.replace ["new", name, @session]
          end

          after(:all) do
            puts @session
            Kernel.system "tmux kill-session -t #{@session}"
          end

          it "creates a project file" do
            capture_io { cli.start }
            expect(file.string).to_not be_empty
            # make sure the output is valid YAML
            expect { YAML.parse file.string }.to_not raise_error
          end
        end

        context "session doesn't exist" do
          before do
            ARGV.replace ["new", name, "sessiondoesnotexist"]
          end

          it "fails" do
            expect { cli.start }.to raise_error RuntimeError
          end
        end
      end

      context "with tmux < 1.6" do
        before do
          ARGV.replace ["new", name, "sessionname"]
          allow(Tmuxinator::Config).to receive(:version).and_return(1.5)
        end

        it "is unsupported" do
          expect { cli.start }.to raise_error RuntimeError
        end
      end
    end
  end

  describe "#copy" do
    before do
      ARGV.replace(["copy", "foo", "bar"])
      allow(Tmuxinator::Config).to receive(:exist?) { true }
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

    context "existing project doesn't exist" do
      before do
        allow(Tmuxinator::Config).to receive(:exist?) { false }
      end

      it "exit with error code" do
        expect { capture_io { cli.start } }.to raise_error SystemExit
      end
    end
  end

  describe "#debug" do
    context "named project" do
      let(:project_with_force_attach) do
        FactoryBot.build(:project_with_force_attach)
      end
      let(:project_with_force_detach) do
        FactoryBot.build(:project_with_force_detach)
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

    context "project config file" do
      before do
        allow(Tmuxinator::Config).to receive_messages(version: 1.9)
        expect(Tmuxinator::Config).to receive(:validate).and_call_original
      end

      it "renders the project if given a valid project config file" do
        ARGV.replace(["debug", "--project-config=#{project_config}"])
        expect { cli.start }.to output(/sample_with_project_config/).to_stdout
      end

      it "does not render the project if given a bogus project config file" do
        ARGV.replace(["debug", "--project-config=bogus.yml"])
        expect { capture_io { cli.start } }.to raise_error(SystemExit)
      end
    end
  end

  describe "#delete" do
    context "with a single argument" do
      before do
        ARGV.replace(["delete", "foo"])
        allow(Thor::LineEditor).to receive_messages(readline: "y")
      end

      context "project exists" do
        before do
          allow(Tmuxinator::Config).to receive(:exist?) { true }
        end

        it "deletes the project" do
          expect(FileUtils).to receive(:rm)
          capture_io { cli.start }
        end
      end

      context "local project exists" do
        before do
          allow(Tmuxinator::Config).to receive(:exist?) { true }
          expect(Tmuxinator::Config).to receive(:project) { "local" }
        end

        it "deletes the local project" do
          expect(FileUtils).to receive(:rm).with("local")
          capture_io { cli.start }
        end
      end

      context "project doesn't exist" do
        before do
          allow(Tmuxinator::Config).to receive(:exist?) { false }
        end

        it "outputs an error message" do
          expect(capture_io { cli.start }[0]).to match(/foo does not exist!/)
        end
      end
    end

    context "with multiple arguments" do
      before do
        ARGV.replace(["delete", "foo", "bar"])
        allow(Thor::LineEditor).to receive_messages(readline: "y")
      end

      context "all projects exist" do
        before do
          allow(Tmuxinator::Config).to receive(:exist?).and_return(true)
        end

        it "deletes the projects" do
          expect(FileUtils).to receive(:rm).exactly(2).times
          capture_io { cli.start }
        end
      end

      context "only one project exists" do
        before do
          allow(Tmuxinator::Config).to receive(:exist?).with(name: "foo") {
            true
          }
          allow(Tmuxinator::Config).to receive(:exist?).with(name: "bar") {
            false
          }
        end

        it "deletes one project" do
          expect(FileUtils).to receive(:rm)
          capture_io { cli.start }
        end

        it "outputs an error message" do
          expect(capture_io { cli.start }[0]).to match(/bar does not exist!/)
        end
      end

      context "all projects do not exist" do
        before do
          allow(Tmuxinator::Config).to receive(:exist?).and_return(false)
        end

        it "outputs multiple error messages" do
          expect(capture_io { cli.start }[0]).
            to match(/foo does not exist!\nbar does not exist!/)
        end
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

    it "deletes the configuration directory(s)" do
      allow(Tmuxinator::Config).to receive(:directories) \
        { [Tmuxinator::Config.xdg, Tmuxinator::Config.home] }
      expect(FileUtils).to receive(:remove_dir).once.
        with(Tmuxinator::Config.xdg)
      expect(FileUtils).to receive(:remove_dir).once.
        with(Tmuxinator::Config.home)
      expect(FileUtils).to receive(:remove_dir).never
      capture_io { cli.start }
    end

    context "$TMUXINATOR_CONFIG specified" do
      it "only deletes projects in that directory" do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("TMUXINATOR_CONFIG").and_return "dir"
        allow(File).to receive(:directory?).with("dir").and_return true
        expect(FileUtils).to receive(:remove_dir).once.with("dir")
        expect(FileUtils).to receive(:remove_dir).never
        capture_io { cli.start }
      end
    end
  end

  describe "#list" do
    before do
      allow(Dir).to receive_messages(:[] => ["/path/to/project.yml"])
    end

    context "set --newline flag " do
      ARGV.replace(["list --newline"])

      it "force output to be one entry per line" do
        expect { capture_io { cli.start } }.to_not raise_error
      end
    end

    context "no arguments are given" do
      ARGV.replace(["list"])

      it "lists all projects " do
        expect { capture_io { cli.start } }.to_not raise_error
      end
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
      expect(Tmuxinator::Doctor).to receive(:installed?)
      expect(Tmuxinator::Doctor).to receive(:editor?)
      expect(Tmuxinator::Doctor).to receive(:shell?)
      capture_io { cli.start }
    end
  end

  describe "#find_project_file" do
    let(:name) { "foobar" }
    let(:path) { Tmuxinator::Config.default_project(name) }

    after(:each) do
      FileUtils.remove_file(path) if File.exist?(path)
    end

    context "when the project file does not already exist" do
      before do
        expect(File).not_to exist(path), "expected file at #{path} not to exist"
      end

      it "should generate a project file" do
        new_path = described_class.new.find_project_file(name, false)
        expect(new_path).to eq path
        expect(File).to exist new_path
      end
    end

    context "when the project file _does_ already exist" do
      let(:extra) { "  - extra: echo 'foobar'" }

      before do
        expect(File).not_to exist(path), "expected file at #{path} not to exist"
        expect(described_class.new.generate_project_file(name, path)).to eq path
        expect(File).to exist path

        File.open(path, "w") do |f|
          f.write(extra)
          f.flush
        end
        expect(File.read(path)).to match %r{#{extra}}
      end

      it "should _not_ generate a new project file" do
        new_path = described_class.new.find_project_file(name, false)
        expect(new_path).to eq path
        expect(File).to exist new_path
        expect(File.read(new_path)).to match %r{#{extra}}
      end
    end
  end

  describe "#generate_project_file" do
    let(:name) { "foobar-#{Time.now.to_i}" }

    it "should always generate a project file" do
      Dir.mktmpdir do |dir|
        path = "#{dir}/#{name}.yml"
        expect(File).not_to exist(path), "expected file at #{path} not to exist"
        new_path = described_class.new.generate_project_file(name, path)
        expect(new_path).to eq path
        expect(File).to exist new_path
      end
    end

    it "should generate a project file using the correct project file path" do
      file = StringIO.new
      allow(File).to receive(:open) { |&block| block.yield file }
      Dir.mktmpdir do |dir|
        path = "#{dir}/#{name}.yml"
        _ = described_class.new.generate_project_file(name, path)
        expect(file.string).to match %r{\A# #{path}$}
      end
    end
  end

  describe "#create_project" do
    before do
      allow(Tmuxinator::Config).to receive_messages(directory: path)
    end

    let(:name) { "sample" }
    let(:custom_name) { nil }
    let(:cli_options) { {} }
    let(:path) { File.expand_path("../../fixtures", __dir__) }

    shared_examples_for :a_proper_project do
      it "should create a valid project" do
        expect(subject).to be_a Tmuxinator::Project
        expect(subject.name).to eq name
      end
    end

    context "when creating a traditional named project" do
      let(:params) do
        {
          name: name,
          custom_name: custom_name
        }
      end
      subject { described_class.new.create_project(params) }

      it_should_behave_like :a_proper_project
    end

    context "attach option" do
      describe "detach" do
        it "sets force_detach to false when no attach argument is provided" do
          project = described_class.new.create_project(name: name)
          expect(project.force_detach).to eq(false)
        end

        it "sets force_detach to true when 'attach: false' is provided" do
          project = described_class.new.create_project(attach: false,
                                                       name: name)
          expect(project.force_detach).to eq(true)
        end

        it "sets force_detach to false when 'attach: true' is provided" do
          project = described_class.new.create_project(attach: true,
                                                       name: name)
          expect(project.force_detach).to eq(false)
        end
      end

      describe "attach" do
        it "sets force_attach to false when no attach argument is provided" do
          project = described_class.new.create_project(name: name)
          expect(project.force_attach).to eq(false)
        end

        it "sets force_attach to true when 'attach: true' is provided" do
          project = described_class.new.create_project(attach: true,
                                                       name: name)
          expect(project.force_attach).to eq(true)
        end

        it "sets force_attach to false when 'attach: false' is provided" do
          project = described_class.new.create_project(attach: false,
                                                       name: name)
          expect(project.force_attach).to eq(false)
        end
      end
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
