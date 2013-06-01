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

  describe "#installed?" do
    context "tmux is installed" do
      before do
        Kernel.stub(:system).with("which tmux > /dev/null") { true }
      end

      it "returns true" do
        expect(Tmuxinator::Config.installed?).to be_true
      end
    end

    context "tmux is installed" do
      before do
        Kernel.stub(:system).with("which tmux > /dev/null") { false }
      end

      it "returns true" do
        expect(Tmuxinator::Config.installed?).to be_true
      end
    end
  end

  describe "#editor?" do
    context "$EDITOR is set" do
      before do
        ENV.stub(:[]).with("EDITOR") { "vim" }
      end

      it "returns true" do
        expect(Tmuxinator::Config.editor?).to be_true
      end
    end

    context "$EDITOR is not set" do
      before do
        ENV.stub(:[]).with("EDITOR") { nil }
      end

      it "returns false" do
        expect(Tmuxinator::Config.editor?).to be_false
      end
    end
  end

  describe "#shell?" do
    context "$SHELL is set" do
      before do
        ENV.stub(:[]).with("SHELL") { "vim" }
      end

      it "returns true" do
        expect(Tmuxinator::Config.shell?).to be_true
      end
    end

    context "$SHELL is not set" do
      before do
        ENV.stub(:[]).with("SHELL") { nil }
      end

      it "returns false" do
        expect(Tmuxinator::Config.shell?).to be_false
      end
    end
  end

  describe "#exists?" do
    before do
      File.stub(:exists? => true)
    end

    it "checks if the given project exists" do
      expect(Tmuxinator::Config.exists?("test")).to be_true
    end
  end

  describe "#project" do
    let(:root) { Tmuxinator::Config.root }
    it "gets the project as path to the yml file" do
      expect(Tmuxinator::Config.project("test")).to eq "#{root}/test.yml"
    end
  end
end
