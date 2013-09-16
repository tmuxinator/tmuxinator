require "spec_helper"

describe Tmuxinator::Window do
  let(:project) { double }
  let(:yaml) do
    {
      "editor" => {
        "pre" => ["echo 'I get run in each pane.  Before each pane command!'", nil],
        "layout" => "main-vertical",
        "panes" => ["vim", nil, "top"]
      }
    }
  end

  let(:window) { Tmuxinator::Window.new(yaml, 0, project) }

  before do
    project.stub(:tmux => "tmux", :name => "test", :base_index => 1)
  end

  describe "#initialize" do
    it "creates an instance" do
      expect(window).to be_a(Tmuxinator::Window)
    end
  end

  describe "#build_panes" do
    it "creates the list of panes" do
      expect(window.panes).to_not be_empty
    end
  end

  describe "#pre" do
    context "pre is a string" do
      before do
        yaml["editor"]["pre"] = "vim"
      end

      it "returns the pre command" do
        expect(window.pre).to eq "vim"
      end
    end


    context "pre is not present" do
      before do
        yaml["editor"].delete("pre")
      end

      it "returns an empty string" do
        expect(window.pre).to eq ""
      end
    end
  end

  describe "#build_commands" do
    context "command is an array" do
      before do
        yaml["editor"] = ["git fetch", "git status"]
      end

      it "returns the flattened command" do
        expect(window.commands).to eq ["tmux send-keys -t test:1 git\\ fetch C-m", "tmux send-keys -t test:1 git\\ status C-m"]
      end
    end

    context "command is a string" do
      before do
        yaml["editor"] = "vim"
      end

      it "returns the command" do
        expect(window.commands).to eq ["tmux send-keys -t test:1 vim C-m"]
      end
    end

    context "command is empty" do
      before do
        yaml["editor"] = ""
      end

      it "returns an empty array" do
        expect(window.commands).to be_empty
      end
    end
  end

  describe "#build_panes" do
    context "no panes" do
      before do
        yaml["editor"]["panes"] = "vim"
      end

      it "creates one pane" do
        expect(window.panes).to be_a(Tmuxinator::Pane)
      end
    end
  end

  describe "#tmux_new_window_command" do
    let(:project) { double(:project) }
    let(:window) { Tmuxinator::Window.new(yaml, 0, project) }

    before do
      project.stub(
        :name => "",
        :tmux => "tmux",
        :root => "/project/tmuxinator",
        :base_index => 1
      )
    end

    it "specifies root path by passing -c to tmux" do
      expect(window.tmux_new_window_command).to include("-c /project/tmuxinator")
    end
  end
end
