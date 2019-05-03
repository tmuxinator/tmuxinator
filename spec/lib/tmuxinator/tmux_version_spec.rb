require "spec_helper"

describe Tmuxinator::TmuxVersion do
  describe ".version" do
    subject { described_class.version }

    before do
      expect(Tmuxinator::Doctor).to receive(:installed?).and_return(true)
      allow_any_instance_of(Kernel).to receive(:`).with(/tmux\s\-V/).
        and_return("tmux #{version}")
    end

    context "master" do
      let(:version) { "master" }
      it { is_expected.to eq Float::INFINITY }
    end

    context "installed" do
      let(:version) { "2.4" }
      it { is_expected.to eq version.to_f }
    end
  end
end
