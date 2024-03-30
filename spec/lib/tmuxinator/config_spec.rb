# frozen_string_literal: true

require "spec_helper"

describe Tmuxinator::Config do
  let(:fixtures_dir) { File.expand_path("../../fixtures", __dir__) }
  let(:xdg_config_dir) { "#{fixtures_dir}/xdg-tmuxinator" }
  let(:home_config_dir) { "#{fixtures_dir}/dot-tmuxinator" }

  describe "#directory" do
    context "environment variable $TMUXINATOR_CONFIG non-blank" do
      it "is $TMUXINATOR_CONFIG" do
        allow(ENV).to receive(:[]).with("TMUXINATOR_CONFIG").
          and_return "expected"
        allow(File).to receive(:directory?).and_return true
        expect(described_class.directory).to eq "expected"
      end
    end

    context "only ~/.tmuxinator exists" do
      it "is ~/.tmuxinator" do
        allow(described_class).to receive(:environment?).and_return false
        allow(described_class).to receive(:xdg?).and_return false
        allow(described_class).to receive(:home?).and_return true

        expect(described_class.directory).to eq described_class.home
      end
    end

    context "only $XDG_CONFIG_HOME/tmuxinator exists" do
      it "is #xdg" do
        allow(described_class).to receive(:environment?).and_return false
        allow(described_class).to receive(:xdg?).and_return true
        allow(described_class).to receive(:home?).and_return false

        expect(described_class.directory).to eq described_class.xdg
      end
    end

    context "both $XDG_CONFIG_HOME/tmuxinator and ~/.tmuxinator exist" do
      it "is #xdg" do
        allow(described_class).to receive(:environment?).and_return false
        allow(described_class).to receive(:xdg?).and_return true
        allow(described_class).to receive(:home?).and_return true

        expect(described_class.directory).to eq described_class.xdg
      end
    end

    context "defaulting to xdg with parent directory(s) that do not exist" do
      it "creates parent directories if required" do
        allow(described_class).to receive(:environment?).and_return false
        allow(described_class).to receive(:xdg?).and_return false
        allow(described_class).to receive(:home?).and_return false

        Dir.mktmpdir do |dir|
          config_parent = "#{dir}/non_existent_parent/s"
          allow(XDG).to receive(:[]).with("CONFIG").and_return config_parent
          expect(described_class.directory).
            to eq "#{config_parent}/tmuxinator"
          expect(File.directory?("#{config_parent}/tmuxinator")).to be true
        end
      end
    end
  end

  describe "#environment" do
    context "environment variable $TMUXINATOR_CONFIG is not empty" do
      it "is $TMUXINATOR_CONFIG" do
        allow(ENV).to receive(:[]).with("TMUXINATOR_CONFIG").
          and_return "expected"
        # allow(XDG).to receive(:[]).with("CONFIG").and_return "expected"
        allow(File).to receive(:directory?).and_return true
        expect(described_class.environment).to eq "expected"
      end
    end

    context "environment variable $TMUXINATOR_CONFIG is nil" do
      it "is an empty string" do
        allow(ENV).to receive(:[]).with("TMUXINATOR_CONFIG").
          and_return nil
        # allow(XDG).to receive(:[]).with("CONFIG").and_return nil
        allow(File).to receive(:directory?).and_return true
        expect(described_class.environment).to eq ""
      end
    end

    context "environment variable $TMUXINATOR_CONFIG is set and empty" do
      it "is an empty string" do
        allow(XDG).to receive(:[]).with("CONFIG").and_return ""
        allow(ENV).to receive(:[]).with("TMUXINATOR_CONFIG").and_return ""
        expect(described_class.environment).to eq ""
      end
    end
  end

  describe "#directories" do
    context "without TMUXINATOR_CONFIG environment" do
      before do
        allow(described_class).to receive(:environment?).and_return false
      end

      it "is empty if no configuration directories exist" do
        allow(File).to receive(:directory?).and_return false
        expect(described_class.directories).to eq []
      end

      it "contains #xdg before #home" do
        allow(described_class).to receive(:xdg).and_return "XDG"
        allow(described_class).to receive(:home).and_return "HOME"
        allow(File).to receive(:directory?).and_return true

        expect(described_class.directories).to eq \
          ["XDG", "HOME"]
      end
    end

    context "with TMUXINATOR_CONFIG environment" do
      before do
        allow(ENV).to receive(:[]).with("TMUXINATOR_CONFIG").
          and_return "TMUXINATOR_CONFIG"
      end
      it "is only [$TMUXINATOR_CONFIG] if set" do
        allow(File).to receive(:directory?).and_return true

        expect(described_class.directories).to eq ["TMUXINATOR_CONFIG"]
      end
    end
  end

  describe "#home" do
    it "is ~/.tmuxinator" do
      expect(described_class.home).to eq "#{ENV['HOME']}/.tmuxinator"
    end
  end

  describe "#xdg" do
    it "is $XDG_CONFIG_HOME/tmuxinator" do
      expect(described_class.xdg).to eq "#{XDG['CONFIG_HOME']}/tmuxinator"
    end
  end

  describe "#sample" do
    it "gets the path of the sample project" do
      expect(described_class.sample).to include("sample.yml")
    end
  end

  describe "#default" do
    it "gets the path of the default config" do
      expect(described_class.default).to include("default.yml")
    end
  end

  describe "#default_or_sample" do
    context "with default? true" do
      before do
        allow(described_class).to receive(:default?).and_return true
        allow(described_class).to receive(:default).and_return("default_path")
      end

      it "gets the default config when it exists" do
        expect(described_class.default_or_sample).to eq "default_path"
      end
    end

    context "with default? false" do
      before do
        allow(described_class).to receive(:default?)
        allow(described_class).to receive(:sample).and_return("sample_path")
      end

      it "falls back to the sample config when the default is missing" do
        expect(described_class.default_or_sample).to eq "sample_path"
      end
    end
  end

  describe "#version" do
    subject { described_class.version }

    before do
      expect(Tmuxinator::Doctor).to receive(:installed?).and_return(true)
      allow_any_instance_of(Kernel).to receive(:`).with(/tmux\s\-V/).
        and_return("tmux #{version}")
    end

    version_mapping = {
      "0.8" => 0.8,
      "1.0" => 1.0,
      "1.9" => 1.9,
      "1.9a" => 1.9,
      "2.4" => 2.4,
      "2.9a" => 2.9,
      "3.0-rc5" => 3.0,
      "next-3.1" => 3.1,
      "master" => Float::INFINITY,
      # Failsafes
      "foobar" => 0.0,
      "-123-" => 123.0,
      "5935" => 5935.0,
      "" => 0.0,
      "!@#^%" => 0.0,
      "2.9ä" => 2.9,
      "v3.5" => 3.5,
      "v3.12.0" => 3.12,
      "v3.12.5" => 3.12
    }.freeze

    version_mapping.each do |string_version, parsed_numeric_version|
      context "when reported version is '#{string_version}'" do
        let(:version) { string_version }
        it { is_expected.to eq parsed_numeric_version }
      end
    end
  end

  describe "#default_path_option" do
    context ">= 1.8" do
      before do
        allow(described_class).to receive(:version).and_return(1.8)
      end

      it "returns -c" do
        expect(described_class.default_path_option).to eq "-c"
      end
    end

    context "< 1.8" do
      before do
        allow(described_class).to receive(:version).and_return(1.7)
      end

      it "returns default-path" do
        expect(described_class.default_path_option).to eq "default-path"
      end
    end
  end

  describe "#default?" do
    let(:directory) { described_class.directory }
    let(:local_yml_default) { described_class::LOCAL_DEFAULTS[0] }
    let(:local_yaml_default) { described_class::LOCAL_DEFAULTS[1] }
    let(:proj_default) { described_class.default }

    context "when the file exists" do
      before do
        allow(File).to receive(:exist?).with(local_yml_default) { false }
        allow(File).to receive(:exist?).with(local_yaml_default) { false }
        allow(File).to receive(:exist?).with(proj_default) { true }
      end

      it "returns true" do
        expect(described_class.default?).to be_truthy
      end
    end

    context "when the file doesn't exist" do
      before do
        allow(File).to receive(:exist?).with(local_yml_default) { false }
        allow(File).to receive(:exist?).with(local_yaml_default) { false }
        allow(File).to receive(:exist?).with(proj_default) { false }
      end

      it "returns true" do
        expect(described_class.default?).to be_falsey
      end
    end
  end

  describe "#configs" do
    before do
      allow(described_class).to receive_messages(xdg: xdg_config_dir)
      allow(described_class).to receive_messages(home: home_config_dir)
    end

    it "gets a sorted list of all projects" do
      allow(described_class).to receive(:environment?).and_return false

      expect(described_class.configs).
        to eq ["both", "both", "dup/local-dup", "home", "local-dup", "xdg"]
    end

    it "lists only projects in $TMUXINATOR_CONFIG when set" do
      allow(ENV).to receive(:[]).with("TMUXINATOR_CONFIG").
        and_return "#{fixtures_dir}/TMUXINATOR_CONFIG"
      expect(described_class.configs).to eq ["TMUXINATOR_CONFIG"]
    end
  end

  describe "#exist?" do
    before do
      allow(File).to receive_messages(exist?: true)
      allow(described_class).to receive_messages(project: "")
    end

    it "checks if the given project exists" do
      expect(described_class.exist?(name: "test")).to be_truthy
    end
  end

  describe "#global_project" do
    let(:directory) { described_class.directory }
    let(:base) { "#{directory}/sample.yml" }
    let(:first_dup) { "#{home_config_dir}/dup/local-dup.yml" }
    let(:yaml) { "#{directory}/yaml.yaml" }

    before do
      allow(described_class).to receive(:environment?).and_return false
      allow(described_class).to receive(:xdg).and_return fixtures_dir
      allow(described_class).to receive(:home).and_return fixtures_dir
    end

    context "with project yml" do
      it "gets the project as path to the yml file" do
        expect(described_class.global_project("sample")).to eq base
      end
    end

    context "with project yaml" do
      it "gets the project as path to the yaml file" do
        expect(Tmuxinator::Config.global_project("yaml")).to eq yaml
      end
    end

    context "without project yml" do
      it "gets the project as path to the yml file" do
        expect(described_class.global_project("new-project")).to be_nil
      end
    end

    context "with duplicate project files" do
      it "is the first .yml file found" do
        expect(described_class.global_project("local-dup")).to eq first_dup
      end
    end
  end

  describe "#local?" do
    it "checks if the given project exists" do
      path = described_class::LOCAL_DEFAULTS[0]
      expect(File).to receive(:exist?).with(path) { true }
      expect(described_class.local?).to be_truthy
    end
  end

  describe "#local_project" do
    let(:default) { described_class::LOCAL_DEFAULTS[0] }

    context "with a project yml" do
      it "gets the project as path to the yml file" do
        expect(File).to receive(:exist?).with(default) { true }
        expect(described_class.local_project).to eq default
      end
    end

    context "without project yml" do
      it "gets the project as path to the yml file" do
        expect(described_class.local_project).to be_nil
      end
    end
  end

  describe "#project" do
    let(:directory) { described_class.directory }
    let(:default) { described_class::LOCAL_DEFAULTS[0] }

    context "with an non-local project yml" do
      before do
        allow(described_class).to receive_messages(directory: fixtures_dir)
      end

      it "gets the project as path to the yml file" do
        expect(described_class.project("sample")).
          to eq "#{directory}/sample.yml"
      end
    end

    context "with a local project, but no global project" do
      it "gets the project as path to the yml file" do
        expect(File).to receive(:exist?).with(default) { true }
        expect(described_class.project("sample")).to eq "./.tmuxinator.yml"
      end
    end

    context "without project yml" do
      let(:expected) { "#{directory}/new-project.yml" }
      it "gets the project as path to the yml file" do
        expect(described_class.project("new-project")).to eq expected
      end
    end
  end

  describe "#validate" do
    let(:local_yml_default) { described_class::LOCAL_DEFAULTS[0] }
    let(:local_yaml_default) { described_class::LOCAL_DEFAULTS[1] }

    context "when a project config file is provided" do
      it "should raise if the project config file can't be found" do
        project_config = "dont-exist.yml"
        regex = /Project config \(#{project_config}\) doesn't exist\./
        expect do
          described_class.validate(project_config: project_config)
        end.to raise_error RuntimeError, regex
      end

      it "should load and validate the project" do
        project_config = File.join(fixtures_dir, "sample.yml")
        expect(described_class.validate(project_config: project_config)).to \
          be_a Tmuxinator::Project
      end

      it "should take precedence over a named project" do
        allow(described_class).to receive_messages(directory: fixtures_dir)
        project_config = File.join(fixtures_dir, "sample_number_as_name.yml")
        project = described_class.validate(name: "sample",
                                           project_config: project_config)
        expect(project.name).to eq("222")
      end

      it "should take precedence over a local project" do
        expect(described_class).not_to receive(:local?)
        project_config = File.join(fixtures_dir, "sample_number_as_name.yml")
        project = described_class.validate(project_config: project_config)
        expect(project.name).to eq("222")
      end
    end

    context "when a project name is provided" do
      it "should raise if the project file can't be found" do
        expect do
          described_class.validate(name: "sample")
        end.to raise_error RuntimeError, %r{Project.+doesn't.exist}
      end

      it "should load and validate the project" do
        expect(described_class).to receive_messages(directory: fixtures_dir)
        expect(described_class.validate(name: "sample")).to \
          be_a Tmuxinator::Project
      end
    end

    context "when no project name is provided" do
      it "should raise if the local project file doesn't exist" do
        expect(File).to receive(:exist?).with(local_yml_default) { false }
        expect(File).to receive(:exist?).with(local_yaml_default) { false }
        expect do
          described_class.validate
        end.to raise_error RuntimeError, %r{Project.+doesn't.exist}
      end

      context "and tmuxinator.yml exists" do
        it "should load and validate the local project" do
          content = File.read(File.join(fixtures_dir, "sample.yml"))

          expect(File).to receive(:exist?).
            with(local_yml_default).
            at_least(:once) { true }
          expect(File).to receive(:read).
            with(local_yml_default).
            and_return(content)
          expect(described_class.validate).to be_a Tmuxinator::Project
        end
      end

      context "and tmuxinator.yaml exists" do
        it "should load and validate the local project" do
          content = File.read(File.join(fixtures_dir, "sample.yml"))

          expect(File).to receive(:exist?).
            with(local_yml_default).
            at_least(:once) { false }
          expect(File).to receive(:exist?).
            with(local_yaml_default).
            at_least(:once) { true }
          expect(File).to receive(:read).
            with(local_yaml_default).
            and_return(content)
          expect(described_class.validate).to be_a Tmuxinator::Project
        end
      end
    end

    context "when no project can be found" do
      it "should raise with NO_PROJECT_FOUND_MSG" do
        expect(described_class).to receive_messages(
          valid_project_config?: false,
          valid_local_project?: false,
          valid_standard_project?: false
        )
        expect do
          described_class.validate
        end.to raise_error RuntimeError, %r{Project could not be found\.}
      end
    end
  end
end
