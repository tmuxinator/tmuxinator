require "spec_helper"

describe Tmuxinator::WemuxSupport do
  let(:klass) { Class.new { include Tmuxinator::WemuxSupport } }
  let(:instance) { klass.new }

  it { expect(instance).to respond_to :wemux? }
  it { expect(instance).to respond_to :load_wemux_overrides }

  describe "#load_wemux_overrides" do
    before { instance.load_wemux_overrides }

    it "adds a render method" do
      expect(instance).to respond_to :render
    end

    it "adds a name method" do
      expect(instance).to respond_to :name
    end

    it "adds a tmux method" do
      expect(instance).to respond_to :tmux
    end
  end

  describe "#render" do
    before { instance.load_wemux_overrides }

    it "renders the template" do
      expect(File).to receive(:read).at_least(:once) { "wemux ls 2>/dev/null" }

      expect(instance.render).to match %r{wemux.ls.2>\/dev\/null}
    end
  end

  describe "#name" do
    before { instance.load_wemux_overrides }

    it { expect(instance.name).to eq "wemux" }
  end

  describe "#tmux" do
    before { instance.load_wemux_overrides }

    it { expect(instance.tmux).to eq "wemux" }
  end
end
