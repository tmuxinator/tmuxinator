require "spec_helper"

describe Tmuxinator::Window do
  let(:yaml) do
    {
      "editor" => {
        "pre" => ["echo 'I get run in each pane.  Before each pane command!'", nil],
        "layout" => "main-vertical",
        "panes" => ["vim", nil, "top"]
      }
    }
  end

  let(:window) { Tmuxinator::Window.new(yaml, 0, nil) }

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
