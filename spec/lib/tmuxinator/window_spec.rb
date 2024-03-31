# frozen_string_literal: true

require "spec_helper"

describe Tmuxinator::Window do
  let(:project) { double }
  let(:panes) { ["vim", nil, "top"] }
  let(:window_name) { "editor" }
  let(:synchronize) { false }
  let(:yaml) do
    {
      window_name => {
        "pre" => [
          "echo 'I get run in each pane.  Before each pane command!'",
          nil
        ],
        "synchronize" => synchronize,
        "layout" => "main-vertical",
        "panes" => panes
      }
    }
  end
  let(:yaml_root) do
    {
      "editor" => {
        "root" => "/project/override",
        "root?" => true,
        "pre" => [
          "echo 'I get run in each pane.  Before each pane command!'",
          nil
        ],
        "layout" => "main-vertical",
        "panes" => panes
      }
    }
  end

  let(:window) { described_class.new(yaml, 0, project) }
  let(:window_root) { described_class.new(yaml_root, 0, project) }

  shared_context "window command context" do
    let(:project) { double(:project) }
    let(:window) { described_class.new(yaml, 0, project) }
    let(:root?) { true }
    let(:root) { "/project/tmuxinator" }

    before do
      allow(project).to receive_messages(
        name: "test",
        tmux: "tmux",
        root: root,
        root?: root?,
        base_index: 1
      )
    end

    let(:tmux_part) { project.tmux }
  end

  before do
    allow(project).to receive_messages(
      tmux: "tmux",
      name: "test",
      base_index: 1,
      pane_base_index: 0,
      root: "/project/tmuxinator",
      root?: true
    )
  end

  describe "#initialize" do
    it "creates an instance" do
      expect(window).to be_a(Tmuxinator::Window)
    end
  end

  describe "#root" do
    context "without window root" do
      it "gets the project root" do
        expect(window.root).to include("/project/tmuxinator")
      end
    end

    context "with window root" do
      it "gets the window root" do
        expect(window_root.root).to include("/project/override")
      end
    end
  end

  describe "#panes" do
    context "with a three element Array" do
      let(:panes) { ["vim", "ls", "top"] }

      it "creates three panes" do
        expect(Tmuxinator::Pane).to receive(:new).exactly(3).times
        window.panes
      end

      it "returns three panes" do
        expect(window.panes).to all be_a_pane.with(
          project: project, tab: window
        )

        expect(window.panes).to match(
          [
            a_pane.with(index: 0).and_commands("vim"),
            a_pane.with(index: 1).and_commands("ls"),
            a_pane.with(index: 2).and_commands("top")
          ]
        )
      end
    end

    context "with a String" do
      let(:panes) { "vim" }

      it "returns one pane in an Array" do
        expect(window.panes.first).to be_a_pane.
          with(index: 0).and_commands("vim")
      end
    end

    context "with nil" do
      let(:panes) { nil }

      it "returns an empty Array" do
        expect(window.panes).to be_empty
      end
    end

    context "titled panes" do
      let(:panes) do
        [
          { "editor" => ["vim"] },
          { "run" => ["cmd1", "cmd2"] },
          "top"
        ]
      end

      it "creates panes with titles" do
        expect(window.panes).to match(
          [
            a_pane.with(index: 0, title: "editor").and_commands("vim"),
            a_pane.with(index: 1, title: "run").and_commands("cmd1", "cmd2"),
            a_pane.with(index: 2, title: nil).and_commands("top")
          ]
        )
      end
    end

    context "nested collections" do
      let(:command1) { "cd /tmp/" }
      let(:command2) { "ls" }

      let(:panes) { ["vim", nested_collection] }

      context "with nested hash" do
        let(:nested_collection) { { pane2: [command1, command2] } }

        it "returns two panes in an Array" do
          expect(window.panes).to match [
            a_pane.with(index: 0).and_commands("vim"),
            a_pane.with(index: 1).and_commands(command1, command2)
          ]
        end
      end

      context "with nested array" do
        let(:nested_collection) { [command1, command2] }

        it "returns two panes in an Array" do
          expect(window.panes).to match [
            a_pane.with(index: 0).and_commands("vim"),
            a_pane.with(index: 1).and_commands(command1, command2)
          ]
        end
      end
    end
  end

  describe "#pre" do
    context "pre is a string" do
      before do
        yaml["editor"]["pre"] = "vim"
      end

      it "returns the pre command" do
        expect(window.pre).to eq "vim"
      end
    end

    context "pre is not present" do
      before do
        yaml["editor"].delete("pre")
      end

      it "returns nil" do
        expect(window.pre).to be_nil
      end
    end
  end

  describe "#build_commands" do
    context "command is an array" do
      before do
        yaml["editor"] = ["git fetch", "git status"]
      end

      it "returns the flattened command" do
        expect(window.commands).to eq [
          "tmux send-keys -t test:1 git\\ fetch C-m",
          "tmux send-keys -t test:1 git\\ status C-m"
        ]
      end
    end

    context "command is a string" do
      before do
        yaml["editor"] = "vim"
      end

      it "returns the command" do
        expect(window.commands).to eq ["tmux send-keys -t test:1 vim C-m"]
      end
    end

    context "command is empty" do
      before do
        yaml["editor"] = ""
      end

      it "returns an empty array" do
        expect(window.commands).to be_empty
      end
    end

    context "command is a hash" do
      before do
        yaml["editor"] = { "layout" => "main-horizontal", "panes" => [nil] }
      end

      it "returns an empty array" do
        expect(window.commands).to be_empty
      end
    end
  end

  describe "#name_options" do
    context "with a name" do
      let(:window_name) { "editor" }

      it "specifies name with tmux name option" do
        expect(window.tmux_window_name_option).to eq "-n #{window_name}"
      end
    end

    context "without a name" do
      let(:window_name) { nil }

      it "specifies no tmux name option" do
        expect(window.tmux_window_name_option).to be_empty
      end
    end
  end

  describe "#synchronize_before?" do
    subject { window.synchronize_before? }

    context "synchronize is 'before'" do
      let(:synchronize) { "before" }

      it { is_expected.to be true }
    end

    context "synchronize is true" do
      let(:synchronize) { true }

      it { is_expected.to be true }
    end

    context "synchronize is 'after'" do
      let(:synchronize) { "after" }

      it { is_expected.to be false }
    end

    context "synchronization disabled" do
      let(:synchronize) { false }

      it { is_expected.to be false }
    end

    context "synchronization not specified" do
      it { is_expected.to be false }
    end
  end

  describe "#synchronize_after?" do
    subject { window.synchronize_after? }

    context "synchronization is 'after'" do
      let(:synchronize) { "after" }

      it { is_expected.to be true }
    end

    context "synchronization is true" do
      let(:synchronize) { true }

      it { is_expected.to be false }
    end

    context "synchronization is 'before'" do
      let(:synchronize) { "before" }

      it { is_expected.to be false }
    end

    context "synchronization disabled" do
      let(:synchronize) { false }

      it { is_expected.to be false }
    end

    context "synchronization not specified" do
      it { is_expected.to be false }
    end
  end

  describe "#tmux_synchronize_panes" do
    include_context "window command context"

    let(:window_option_set_part) { "set-window-option" }
    let(:target_part) { "-t #{window.tmux_window_target}" }
    let(:synchronize_panes_part) { "synchronize-panes" }

    context "synchronization enabled" do
      let(:synchronize) { true }
      let(:enabled) { "on" }

      let(:full_command) do
        "#{tmux_part} #{window_option_set_part} #{target_part} #{synchronize_panes_part} #{enabled}"
      end

      it "should set the synchronize-panes window option on" do
        expect(window.tmux_synchronize_panes).to eq full_command
      end
    end
  end

  describe "#tmux_new_window_command" do
    include_context "window command context"

    let(:window_part) { "new-window" }
    let(:name_part) { window.tmux_window_name_option }
    let(:target_part) { "-t #{window.tmux_window_target}" }
    let(:path_part) { "#{path_option} #{project.root}" }

    let(:path_option) { "-c" }
    let(:full_command) do
      "#{tmux_part} #{window_part} #{path_part} #{target_part} #{name_part}"
    end

    before do
      allow(Tmuxinator::Config).to receive(:default_path_option) { path_option }
    end

    it "constructs window command with path, target, and name options" do
      expect(window.tmux_new_window_command).to eq full_command
    end

    context "root not set" do
      let(:root?) { false }
      let(:root) { nil }

      let(:path_part) { nil }

      it "has an extra space instead of path_part" do
        expect(window.tmux_new_window_command).to eq full_command
      end
    end

    context "name not set" do
      let(:window_name) { nil }
      let(:full_command) do
        "#{tmux_part} #{window_part} #{path_part} #{target_part} "
      end

      it "does not set name option" do
        expect(window.tmux_new_window_command).to eq full_command
      end
    end
  end

  describe "#tmux_select_first_pane" do
    it "targets the pane based on the configured pane_base_index" do
      expect(window.tmux_select_first_pane).to eq("tmux select-pane -t test:1.0")
    end
  end
end
