require "spec_helper"

describe Tmuxinator::Tab do
  let(:yaml) do
    {
      "editor" => {
        "pre" => ["echo 'I get run in each pane.  Before each pane command!'", nil],
        "layout" => "main-vertical",
        "panes" => ["vim", nil, "top"]
      }
    }
  end

  let(:tab) { Tmuxinator::Tab.new(yaml) }

  describe "#initialize" do
    it "creates an instance" do
      expect(tab).to be_a(Tmuxinator::Tab)
    end
  end

  describe "#build_panes" do
    it "creates the list of panes" do
      expect(tab.panes).to_not be_empty
    end
  end
end
