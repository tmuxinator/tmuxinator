require "spec_helper"

describe Tmuxinator::Window do
  let(:project) { double }
  let(:panes) { ["vim", nil, "top"] }
  let(:yaml) do
    {
      "editor" => {
        "pre" => ["echo 'I get run in each pane.  Before each pane command!'", nil],
        "layout" => "main-vertical",
        "panes" => panes
      }
    }
  end
  let(:yaml_root) do
    {
      "editor" => {
        "root" => "/project/override",
        "root?" => true,
        "pre" => ["echo 'I get run in each pane.  Before each pane command!'", nil],
        "layout" => "main-vertical",
        "panes" => panes
      }
    }
  end

  let(:window) { Tmuxinator::Window.new(yaml, 0, project) }
  let(:window_root) { Tmuxinator::Window.new(yaml_root, 0, project) }

  before do
    allow(project).to receive_messages(
       :tmux => "tmux",
       :name => "test",
       :base_index => 1,
       :root => "/project/tmuxinator",
       :root? => true
     )
  end

  describe "#initialize" do
    it "creates an instance" do
      expect(window).to be_a(Tmuxinator::Window)
    end
  end

  describe "#root" do
    context "without window root" do
      it "gets the project root" do
        expect(window.root).to include("/project/tmuxinator")
      end
    end

    context "with window root" do
      it "gets the window root" do
        expect(window_root.root).to include("/project/override")
      end
    end
  end

  describe "#panes" do
    let(:pane) { double(:pane) }

    before do
      allow(Tmuxinator::Pane).to receive_messages :new => pane
    end

    context "with a three element Array" do
      let(:panes) { ["vim", nil, "top"] }

      it "creates three panes" do
        expect(Tmuxinator::Pane).to receive(:new).exactly(3).times
        window.panes
      end

      it "returns three panes" do
        expect(window.panes).to eql [pane, pane, pane]
      end
    end

    context "with a String" do
      let(:panes) { "vim" }

      it "creates one pane" do
        expect(Tmuxinator::Pane).to receive(:new).once
        window.panes
      end

      it "returns one pane in an Array" do
        expect(window.panes).to eql [pane]
      end
    end

    context "with nil" do
      let(:panes) { nil }

      it "doesn't create any panes" do
        expect(Tmuxinator::Pane).to_not receive(:new)
        window.panes
      end

      it "returns an empty Array" do
        expect(window.panes).to be_empty
      end
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

      it "returns nil" do
        expect(window.pre).to be_nil
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

  describe "#tmux_new_window_command" do
    let(:project) { double(:project) }
    let(:window) { Tmuxinator::Window.new(yaml, 0, project) }

    before do
      allow(project).to receive_messages(
        :name => "",
        :tmux => "tmux",
        :root => "/project/tmuxinator",
        :root? => true,
        :base_index => 1
      )
    end

    context "tmux 1.6 and below" do
      before do
        allow(Tmuxinator::Config).to receive_messages(:version => 1.6)
      end

      it "specifies root path by passing default-path to tmux" do
        expect(window.tmux_new_window_command).to include("default-path /project/tmuxinator")
      end
    end
  end
end
