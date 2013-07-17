require "spec_helper"

describe Tmuxinator::Pane do
  it "creates an instance" do
    expect(Tmuxinator::Pane.new("vim", 0, nil, nil)).to be_a(Tmuxinator::Pane)
  end
end
