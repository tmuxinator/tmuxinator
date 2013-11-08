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

  describe "#default?" do
    let(:root) { Tmuxinator::Config.root }
    context "when the file exists" do
        before do
            puts Tmuxinator::Config.default
          File.stub(:exists?).with(Tmuxinator::Config.default) { true }
        end
        it "returns true" do
          expect(Tmuxinator::Config.default?).to be_true
        end
    end
    context "when the file doesn't exist" do
        before do
            puts Tmuxinator::Config.default
          File.stub(:exists?).with(Tmuxinator::Config.default) { false }
        end
        it "returns true" do
          expect(Tmuxinator::Config.default?).to be_false
        end
    end
  end

  describe "#configs" do
    before do
      Dir.stub(:[] => ["test.yml"])
    end

    it "gets a list of all projects" do
      expect(Tmuxinator::Config.configs).to include("test")
    end
  end

  describe "#installed?" do
    context "tmux is installed" do
      before do
        Kernel.stub(:system) { true }
      end

      it "returns true" do
        expect(Tmuxinator::Config.installed?).to be_true
      end
    end

    context "tmux is not installed" do
      before do
        Kernel.stub(:system) { false }
      end

      it "returns true" do
        expect(Tmuxinator::Config.installed?).to be_false
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
      Tmuxinator::Config.stub(:project => "")
    end

    it "checks if the given project exists" do
      expect(Tmuxinator::Config.exists?("test")).to be_true
    end
  end

  describe "#project" do
    let(:root) { Tmuxinator::Config.root }

    before do
      path = File.expand_path("../../../fixtures/", __FILE__)
      Tmuxinator::Config.stub(:root => path)
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
