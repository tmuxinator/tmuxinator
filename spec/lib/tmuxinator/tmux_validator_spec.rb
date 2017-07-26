require "spec_helper"
describe Tmuxinator do
  context "tmux has not been installed or is not available" do
    it "raises a useful exception" do
      allow(Tmuxinator::TmuxValidator).
        to receive(:tmux_is_not_available).
        and_return true
      expect { Tmuxinator::TmuxValidator::validate! }.
        to raise_error RuntimeError,
                       Tmuxinator::TmuxValidator::TMUX_IS_NOT_AVAILABLE_MESSAGE
    end
  end
end
