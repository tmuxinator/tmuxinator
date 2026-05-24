# frozen_string_literal: true

require "spec_helper"

describe "tmuxinator debug snapshots" do
  let(:cli) { Tmuxinator::Cli }
  let(:snapshot_root) { File.expand_path("../snapshots/debug", __dir__) }

  around do |example|
    original_argv = ARGV.dup
    example.run
    ARGV.replace(original_argv)
  end

  before do
    allow_any_instance_of(Tmuxinator::Project).
      to receive(:extract_tmux_config).
      and_return({ "base-index" => "0", "pane-base-index" => "0" })
    allow_any_instance_of(Tmuxinator::Project).
      to receive(:tmux_has_session?).
      and_return(false)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("SHELL").and_return("/bin/bash")
  end

  {
    "1.6" => 1.6,
    "1.8" => 1.8,
    "2.6" => 2.6,
  }.each do |version_label, version|
    {
      "basic" => "spec/fixtures/interface/basic.yml",
      "pane_titles" => "spec/fixtures/interface/pane_titles.yml",
    }.each do |fixture_name, fixture_path|
      it "matches #{fixture_name} output for tmux #{version_label}" do
        allow(Tmuxinator::Config).to receive(:version).and_return(version)

        ARGV.replace(["debug", "--project-config=#{fixture_path}"])
        output, _err = capture_io { cli.start }

        snapshot_path = File.join(
          snapshot_root,
          version_label,
          "#{fixture_name}.sh"
        )

        expect(output).to eq("#{File.read(snapshot_path)}\n")
      end
    end
  end

  it "normalizes tmux session targets for project names with separators" do
    allow(Tmuxinator::Config).to receive(:version).and_return(2.6)

    ARGV.replace([
                   "debug",
                   "--project-config=spec/fixtures/interface/session_name.yml"
                 ])
    output, _err = capture_io { cli.start }

    snapshot_path = File.join(snapshot_root, "2.6", "session_name.sh")

    expect(output).to eq("#{File.read(snapshot_path)}\n")
  end
end
