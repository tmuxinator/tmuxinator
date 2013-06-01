require "spec_helper"

describe Tmuxinator::Pane do
  it "creates an instance" do
    expect(Tmuxinator::Pane.new("vim")).to be_a(Tmuxinator::Pane)
  end
end
