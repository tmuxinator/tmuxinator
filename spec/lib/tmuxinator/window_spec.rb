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
end
