require "spec_helper"

describe Tmuxinator::Project do
  let(:project) { FactoryGirl.build(:project) }
  let(:project_with_deprecations) { FactoryGirl.build(:project_with_deprecations) }
  let(:project_with_erb) { FactoryGirl.build(:project_with_erb) }

  describe "#initialize" do
    context "valid yaml" do
      it "creates an instance" do
        expect(project).to be_a(Tmuxinator::Project)
      end
    end
  end

  describe "#render" do
    it "renders the tmux config" do
      expect(project.render).to_not be_empty
    end
  end

  describe "#windows" do
    context "without deprecations" do
      it "gets the list of windows" do
        expect(project.windows).to_not be_empty
      end
    end

    context "with deprecations" do
      it "still gets the list of windows" do
        expect(project_with_deprecations.windows).to_not be_empty
      end
    end
  end

  describe "#root" do
    context "without deprecations" do
      it "gets the root" do
        expect(project.root).to eq "~/test"
      end
    end

    context "with deprecations" do
      it "still gets the root" do
        expect(project_with_deprecations.root).to eq "~/test"
      end
    end

    context "with ERB" do
      it "gets the root" do
        expect(project_with_erb.root).to eq "~/test"
      end
    end
  end

  describe "#name" do
    context "without deprecations" do
      it "gets the name" do
        expect(project.name).to eq "sample"
      end
    end

    context "with deprecations" do
      it "still gets the name" do
        expect(project_with_deprecations.name).to eq "sample"
      end
    end

    context "with ERB" do
      it "gets the name" do
        expect(project_with_erb.name).to eq "sample"
      end
    end
  end

  describe "#pre_window" do
    it "gets the pre_window command" do
      expect(project.pre_window).to eq "rbenv shell 2.0.0-p247"
    end

    context "with deprecations" do
      context "rbenv option is present" do
        before do
          project.stub(:rbenv? => true)
          project.stub_chain(:yaml, :[]).and_return("2.0.0-p247")
        end

        it "still gets the correct pre_window command" do
          expect(project.pre_window).to eq "rbenv shell 2.0.0-p247"
        end
      end

      context "rvm option is present" do
        before do
          project.stub(:rbenv? => false)
          project.stub_chain(:yaml, :[]).and_return("ruby-2.0.0-p247")
        end

        it "still gets the correct pre_window command" do
          expect(project.pre_window).to eq "rvm use ruby-2.0.0-p247"
        end
      end

      context "pre_tab is present" do
        before do
          project.stub(:rbenv? => false)
          project.stub(:pre_tab? => true)
        end

        it "still gets the correct pre_window command" do
          expect(project.pre_window).to be_nil
        end
      end
    end
  end

  describe "#socket" do
    context "socket path is present" do
      before do
        project.stub(:socket_path => "/tmp")
      end

      it "gets the socket path" do
        expect(project.socket).to eq " -S /tmp"
      end
    end
  end

  describe "#tmux_options" do
    context "no tmux options" do
      before do
        project.stub(:tmux_options? => false)
      end

      it "returns nothing" do
        expect(project.tmux_options).to eq ""
      end
    end

    context "with deprecations" do
      before do
        project_with_deprecations.stub(:cli_args? => true)
      end

      it "still gets the tmux options" do
        expect(project_with_deprecations.tmux_options).to eq " -f ~/.tmux.mac.conf"
      end
    end
  end

  describe "#base_index" do
    context "pane base index present" do
      before do
        project.stub(:get_pane_base_index => "1")
        project.stub(:get_base_index => "1")
      end

      it "gets the pane base index" do
        expect(project.base_index).to eq 1
      end
    end

    context "pane base index no present" do
      before do
        project.stub(:get_pane_base_index => nil)
        project.stub(:get_base_index => "0")
      end

      it "gets the base index" do
        expect(project.base_index).to eq 0
      end
    end
  end

  describe "#window" do
    it "gets the window and index for tmux" do
      expect(project.window(1)).to eq "sample:1"
    end
  end

  describe "#name?" do
    context "name is present" do
      it "returns true" do
        expect(project.name?).to be_true
      end
    end
  end

  describe "#windows?" do
    context "windows are present" do
      it "returns true" do
        expect(project.windows?).to be_true
      end
    end
  end

  describe "#root?" do
    context "root are present" do
      it "returns true" do
        expect(project.root?).to be_true
      end
    end
  end

  describe "#send_keys" do
    context "no command for window" do
      it "returns empty string" do
        expect(project.send_keys("", 1)).to be_empty
      end
    end

    context "command for window is not empty" do
      it "returns the tmux command" do
        expect(project.send_keys("vim", 1)).to eq "tmux -f ~/.tmux.mac.conf -L foo send-keys -t sample:1 vim C-m"
      end
    end
  end

  describe "#send_pane_command" do
    context "no command for pane" do
      it "returns empty string" do
        expect(project.send_pane_command("", 0, 0)).to be_empty
      end
    end

    context "command for pane is not empty" do
      it "returns the tmux command" do
        expect(project.send_pane_command("vim", 1, 0)).to eq "tmux -f ~/.tmux.mac.conf -L foo send-keys -t sample:1 vim C-m"
      end
    end
  end

  describe "#deprecations" do
    context "without deprecations" do
      it "is empty" do
        expect(project.deprecations).to be_empty
      end
    end

    context "with deprecations" do
      it "is not empty" do
        expect(project_with_deprecations.deprecations).to_not be_empty
      end
    end
  end

  describe "#command" do
    let(:window) { project.windows.keep_if { |w| w.name == "shell" }.first }

    it "flattens the command" do
      expect(window.command).to eq("git pull && git merge")
    end
  end

  describe "#pre" do
    subject(:pre) { project.pre }

    context "pre in yaml is string" do
      before { project.yaml["pre"] = "mysql.server start" }

      it "returns the string" do
        expect(pre).to eq("mysql.server start")
      end
    end

    context "pre in yaml is Array" do
      before {
        project.yaml["pre"] = [
          "mysql.server start",
          "memcached -d"
        ]
      }

      it "joins array using ;" do
        expect(pre).to eq("mysql.server start; memcached -d")
      end
    end
  end
end
