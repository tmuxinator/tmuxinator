# frozen_string_literal: true

require "spec_helper"

describe Tmuxinator::Pane do
  let(:klass) { described_class }
  let(:instance) { klass.new(index, project, window, *commands) }
  let(:instance_with_title) do
    klass.new(index, project, window, *commands, title: title)
  end
  let(:index) { 0 }
  let(:project) { double }
  let(:window) { double }
  let(:commands) { ["vim", "bash"] }
  let(:title) { "test (a test)" }

  before do
    allow(project).to receive(:name).and_return "foo"
    allow(project).to receive(:base_index).and_return 0
    allow(project).to receive(:pane_base_index).and_return 1
    allow(project).to receive(:tmux).and_return "tmux"

    allow(window).to receive(:project).and_return project
    allow(window).to receive(:index).and_return 0
  end

  subject { instance }

  it "creates an instance" do
    expect(subject).to be_a(Tmuxinator::Pane)
  end

  it { expect(subject.tmux_window_and_pane_target).to eql "foo:0.1" }

  it "does not set pane title" do
    expect(subject.tmux_set_title).to be_nil
  end

  context "when title is provided" do
    subject { instance_with_title }

    it "sets pane title" do
      expect(subject.tmux_set_title).to eql(
        "tmux select-pane -t foo:0.1 -T test\\ \\(a\\ test\\)"
      )
    end
  end
end
