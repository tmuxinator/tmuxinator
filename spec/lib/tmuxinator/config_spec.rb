require "spec_helper"

describe Tmuxinator::Config do
  describe "#root" do
    it "is ~/.tmuxintaor" do
      expect(Tmuxinator::Config.root).to eq "#{ENV["HOME"]}/.tmuxinator"
    end
  end

  describe "#sample" do
    it "gets the path of the sample project" do
      expect(Tmuxinator::Config.sample).to include("sample.yml")
    end
  end

  describe "#default" do
    it "gets the path of the default config" do
      expect(Tmuxinator::Config.default).to include("default.yml")
    end
  end

  describe "#default_path_option" do
    context ">= 1.8" do
      before do
        allow(Tmuxinator::Config).to receive(:version).and_return(1.8)
      end

      it "returns -c" do
        expect(Tmuxinator::Config.default_path_option).to eq "-c"
      end
    end

    context "< 1.8" do
      before do
        allow(Tmuxinator::Config).to receive(:version).and_return(1.7)
      end

      it "returns default-path" do
        expect(Tmuxinator::Config.default_path_option).to eq "default-path"
      end
    end
  end

  describe "#default?" do
    let(:root) { Tmuxinator::Config.root }

    context "when the file exists" do
      before do
        allow(File).to receive(:exists?).with(Tmuxinator::Config.default) { true }
      end

      it "returns true" do
        expect(Tmuxinator::Config.default?).to be_truthy
      end
    end

    context "when the file doesn't exist" do
      before do
        allow(File).to receive(:exists?).with(Tmuxinator::Config.default) { false }
      end

      it "returns true" do
        expect(Tmuxinator::Config.default?).to be_falsey
      end
    end
  end

  describe "#configs" do
    before do
      allow(Dir).to receive_messages(:[] => ["test.yml"])
    end

    it "gets a list of all projects" do
      expect(Tmuxinator::Config.configs).to include("test")
    end
  end

  describe "#installed?" do
    context "tmux is installed" do
      before do
        allow(Kernel).to receive(:system) { true }
      end

      it "returns true" do
        expect(Tmuxinator::Config.installed?).to be_truthy
      end
    end

    context "tmux is not installed" do
      before do
        allow(Kernel).to receive(:system) { false }
      end

      it "returns true" do
        expect(Tmuxinator::Config.installed?).to be_falsey
      end
    end
  end

  describe "#editor?" do
    context "$EDITOR is set" do
      before do
        allow(ENV).to receive(:[]).with("EDITOR") { "vim" }
      end

      it "returns true" do
        expect(Tmuxinator::Config.editor?).to be_truthy
      end
    end

    context "$EDITOR is not set" do
      before do
        allow(ENV).to receive(:[]).with("EDITOR") { nil }
      end

      it "returns false" do
        expect(Tmuxinator::Config.editor?).to be_falsey
      end
    end
  end

  describe "#shell?" do
    context "$SHELL is set" do
      before do
        allow(ENV).to receive(:[]).with("SHELL") { "vim" }
      end

      it "returns true" do
        expect(Tmuxinator::Config.shell?).to be_truthy
      end
    end

    context "$SHELL is not set" do
      before do
        allow(ENV).to receive(:[]).with("SHELL") { nil }
      end

      it "returns false" do
        expect(Tmuxinator::Config.shell?).to be_falsey
      end
    end
  end

  describe "#exists?" do
    before do
      allow(File).to receive_messages(:exists? => true)
      allow(Tmuxinator::Config).to receive_messages(:project => "")
    end

    it "checks if the given project exists" do
      expect(Tmuxinator::Config.exists?("test")).to be_truthy
    end
  end

  describe "#project" do
    let(:root) { Tmuxinator::Config.root }

    before do
      path = File.expand_path("../../../fixtures/", __FILE__)
      allow(Tmuxinator::Config).to receive_messages(:root => path)
    end

    context "with project yml" do
      it "gets the project as path to the yml file" do
        expect(Tmuxinator::Config.project("sample")).to eq "#{root}/sample.yml"
      end
    end

    context "without project yml" do
      it "gets the project as path to the yml file" do
        expect(Tmuxinator::Config.project("new-project")).to eq "#{root}/new-project.yml"
      end
    end
  end
end
