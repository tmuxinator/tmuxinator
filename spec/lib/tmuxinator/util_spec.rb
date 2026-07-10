# frozen_string_literal: true

require "spec_helper"

describe Tmuxinator::Util do
  let(:util) { Object.new.extend(Tmuxinator::Util) }

  describe "#current_session_name" do
    def with_env(key, value)
      had_key = ENV.key?(key)
      original = ENV[key]
      if value.nil?
        ENV.delete(key)
      else
        ENV[key] = value
      end
      yield
    ensure
      if had_key
        ENV[key] = original
      else
        ENV.delete(key)
      end
    end

    context "when TMUX is not set" do
      it "returns an empty string without invoking the shell" do
        with_env("TMUX", nil) do
          expect(util).not_to receive(:`)
          expect(util.current_session_name).to eq("")
        end
      end
    end

    context "when TMUX is set" do
      it "returns the current tmux session name" do
        with_env("TMUX", "/tmp/tmux-1000/default,1,0") do
          expect(util).to receive(:`).
            with('tmux display-message -p "#S"').
            and_return("flash\n")

          expect(util.current_session_name).to eq("flash")
        end
      end
    end
  end
end
