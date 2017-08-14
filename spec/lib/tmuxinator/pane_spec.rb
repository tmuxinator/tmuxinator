require "spec_helper"

describe Tmuxinator::Pane do
  let(:klass) { described_class }
  let(:instance) { klass.new(index, nil, project, window, *commands) }
  # let(:index) { "vim" }
  # let(:project) { 0 }
  # let(:tab) { nil }
  # let(:commands) { nil }
  let(:index) { 0 }
  let(:project) { double }
  let(:window) { double }
  let(:commands) { ["vim", "bash"] }

  before do
    allow(project).to receive(:name).and_return "foo"
    allow(project).to receive(:base_index).and_return 0

    allow(window).to receive(:project).and_return project
    allow(window).to receive(:index).and_return 0
  end

  subject { instance }

  it "creates an instance" do
    expect(subject).to be_a(Tmuxinator::Pane)
  end

  it { expect(subject.tmux_window_and_pane_target).to eql "foo:0.0" }
end
