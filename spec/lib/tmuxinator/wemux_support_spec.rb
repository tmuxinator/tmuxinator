# frozen_string_literal: true

require "spec_helper"

describe Tmuxinator::WemuxSupport do
  let(:klass) { Class.new }
  let(:instance) { klass.new }

  before { instance.extend Tmuxinator::WemuxSupport }

  describe "#render" do
    it "renders the template" do
      expect(File).to receive(:read).at_least(:once) { "wemux ls 2>/dev/null" }

      expect(instance.render).to match %r{wemux.ls.2>\/dev\/null}
    end
  end

  describe "#name" do
    it { expect(instance.name).to eq "wemux" }
  end

  describe "#tmux" do
    it { expect(instance.tmux).to eq "wemux" }
  end
end
