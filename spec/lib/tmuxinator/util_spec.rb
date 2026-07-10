# frozen_string_literal: true

require "spec_helper"

describe Tmuxinator::Util do
  let(:util) { Object.new.extend(Tmuxinator::Util) }

  describe "#current_session_name" do
    context "when TMUX is not set" do
      it "returns an empty string without invoking the shell" do
        original = ENV.delete("TMUX")
        begin
          expect(util).not_to receive(:`)
          expect(util.current_session_name).to eq("")
        ensure
          ENV["TMUX"] = original if original
        end
      end
    end

    context "when TMUX is set" do
      it "returns the current tmux session name" do
        original = ENV["TMUX"]
        ENV["TMUX"] = "/tmp/tmux-1000/default,1,0"
        begin
          expect(util).to receive(:`).
            with('tmux display-message -p "#S"').
            and_return("flash\n")

          expect(util.current_session_name).to eq("flash")
        ensure
          if original
            ENV["TMUX"] = original
          else
            ENV.delete("TMUX")
          end
        end
      end
    end
  end
end
