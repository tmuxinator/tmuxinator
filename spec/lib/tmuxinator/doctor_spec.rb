# frozen_string_literal: true

require "spec_helper"

describe Tmuxinator::Doctor do
  describe ".installed?" do
    context "tmux is installed" do
      before do
        allow(Kernel).to receive(:system) { true }
      end

      it "returns true" do
        expect(described_class.installed?).to be_truthy
      end
    end

    context "tmux is not installed" do
      before do
        allow(Kernel).to receive(:system) { false }
      end

      it "returns false" do
        expect(described_class.installed?).to be_falsey
      end
    end
  end

  describe ".editor?" do
    context "$EDITOR is set" do
      before do
        allow(ENV).to receive(:[]).with("EDITOR") { "vim" }
      end

      it "returns true" do
        expect(described_class.editor?).to be_truthy
      end
    end

    context "$EDITOR is not set" do
      before do
        allow(ENV).to receive(:[]).with("EDITOR") { nil }
      end

      it "returns false" do
        expect(described_class.editor?).to be_falsey
      end
    end
  end

  describe ".shell?" do
    context "$SHELL is set" do
      before do
        allow(ENV).to receive(:[]).with("SHELL") { "vim" }
      end

      it "returns true" do
        expect(described_class.shell?).to be_truthy
      end
    end

    context "$SHELL is not set" do
      before do
        allow(ENV).to receive(:[]).with("SHELL") { nil }
      end

      it "returns false" do
        expect(described_class.shell?).to be_falsey
      end
    end
  end
end
