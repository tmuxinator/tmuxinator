# frozen_string_literal: true

require "spec_helper"

describe Tmuxinator::Project do
  let(:project) { FactoryBot.build(:project) }
  let(:project_with_custom_name) do
    FactoryBot.build(:project_with_custom_name)
  end
  let(:project_with_number_as_name) do
    FactoryBot.build(:project_with_number_as_name)
  end
  let(:project_with_emoji_as_name) do
    FactoryBot.build(:project_with_emoji_as_name)
  end
  let(:project_with_literals_as_window_name) do
    FactoryBot.build(:project_with_literals_as_window_name)
  end
  let(:project_with_deprecations) do
    FactoryBot.build(:project_with_deprecations)
  end
  let(:project_with_force_attach) do
    FactoryBot.build(:project_with_force_attach)
  end
  let(:project_with_force_detach) do
    FactoryBot.build(:project_with_force_detach)
  end

  let(:wemux_project) { FactoryBot.build(:wemux_project) }
  let(:noname_project) { FactoryBot.build(:noname_project) }
  let(:noroot_project) { FactoryBot.build(:noroot_project) }
  let(:nameless_window_project) do
    FactoryBot.build(:nameless_window_project)
  end

  let(:project_with_alias) do
    FactoryBot.build(:project_with_alias)
  end

  it "should include Hooks" do
    expect(project).to be_kind_of(Tmuxinator::Hooks::Project)
  end

  describe "#initialize" do
    context "valid yaml" do
      it "creates an instance" do
        expect(project).to be_a(Tmuxinator::Project)
      end
    end
  end

  describe "#render" do
    it "renders the tmux config" do
      expect(project.render).to_not be_empty
    end

    context "wemux" do
      it "renders the wemux config" do
        expect(wemux_project.render).to_not be_empty
      end
    end

    context "custom name" do
      it "renders the tmux config with custom name" do
        rendered = project_with_custom_name.render
        expect(rendered).to_not be_empty
        expect(rendered).to include("custom")
        expect(rendered).to_not include("sample")
      end
    end

    context "with alias" do
      it "renders the tmux config" do
        rendered = project_with_alias.render
        expect(rendered).to_not be_empty
        expect(rendered).to include("alias_is_working")
      end
    end
  end

  describe "#tmux_has_session?" do
    context "no active sessions" do
      before do
        tmux = project.tmux_command
        cmd = "#{tmux} -f ~/.tmux.mac.conf -L foo ls 2> /dev/null"
        resp = ""
        call_tmux_ls = receive(:`).with(cmd).at_least(:once).and_return(resp)

        expect(project).to call_tmux_ls
      end

      it "should return false if no sessions are found" do
        expect(project.tmux_has_session?("no server running")).to be false
      end
    end

    context "active sessions" do
      before do
        cmd = "#{project.tmux} ls 2> /dev/null"
        resp = ""\
          "foo: 1 window (created Sun May 25 10:12:00 1986) [0x0] (detached)\n"\
          "bar: 1 window (created Sat Sept 01 00:00:00 1990) [0x0] (detached)"
        call_tmux_ls = receive(:`).with(cmd).at_least(:once).and_return(resp)

        expect(project).to call_tmux_ls
      end

      it "should return true only when `tmux ls` has the named session" do
        expect(project.tmux_has_session?("foo")).to be true
        expect(project.tmux_has_session?("bar")).to be true
        expect(project.tmux_has_session?("quux")).to be false
      end

      it "should return false if a partial (prefix) match is found" do
        expect(project.tmux_has_session?("foobar")).to be false
      end
    end
  end

  describe "#windows" do
    context "without deprecations" do
      it "gets the list of windows" do
        expect(project.windows).to_not be_empty
      end
    end

    context "with deprecations" do
      it "still gets the list of windows" do
        expect(project_with_deprecations.windows).to_not be_empty
      end
    end
  end

  describe "#root" do
    context "without deprecations" do
      it "gets the root" do
        expect(project.root).to include("test")
      end
    end

    context "with deprecations" do
      it "still gets the root" do
        expect(project_with_deprecations.root).to include("test")
      end
    end

    context "without root" do
      it "doesn't throw an error" do
        expect { noroot_project.root }.to_not raise_error
      end
    end
  end

  describe "#name" do
    context "without deprecations" do
      it "gets the name" do
        expect(project.name).to eq "sample"
      end
    end

    context "with deprecations" do
      it "still gets the name" do
        expect(project_with_deprecations.name).to eq "sample"
      end
    end

    context "wemux" do
      it "is wemux" do
        expect(wemux_project.name).to eq "wemux"
      end
    end

    context "without name" do
      it "displays error message" do
        expect { noname_project.name }.to_not raise_error
      end
    end

    context "as number" do
      it "will gracefully handle a name given as a number" do
        rendered = project_with_number_as_name
        expect(rendered.name.to_i).to_not equal 0
      end
    end

    context "as emoji" do
      it "will gracefully handle a name given as an emoji" do
        rendered = project_with_emoji_as_name
        # needs to allow for \\ present in shellescape'd project name
        expect(rendered.name).to match(/^\\*🍩/)
      end
    end

    context "window as non-string literal" do
      it "will gracefully handle a window name given as a non-string literal" do
        rendered = project_with_literals_as_window_name
        expect(rendered.windows.map(&:name)).to match_array(
          %w(222 222333 111222333444555666777 222.3 4e5 4E5
             true false nil // /sample/)
        )
      end
    end
  end

  describe "#pre_window" do
    subject(:pre_window) { project.pre_window }

    context "pre_window in yaml is string" do
      before { project.yaml["pre_window"] = "mysql.server start" }

      it "returns the string" do
        expect(pre_window).to eq("mysql.server start")
      end
    end

    context "pre_window in yaml is Array" do
      before do
        project.yaml["pre_window"] = [
          "mysql.server start",
          "memcached -d"
        ]
      end

      it "joins array using ;" do
        expect(pre_window).to eq("mysql.server start; memcached -d")
      end
    end

    context "with deprecations" do
      context "rbenv option is present" do
        before do
          allow(project).to receive_messages(rbenv?: true)
          allow(project).to \
            receive_message_chain(:yaml, :[]).and_return("2.0.0-p247")
        end

        it "still gets the correct pre_window command" do
          expect(project.pre_window).to eq "rbenv shell 2.0.0-p247"
        end
      end

      context "rvm option is present" do
        before do
          allow(project).to receive_messages(rbenv?: false)
          allow(project).to \
            receive_message_chain(:yaml, :[]).and_return("ruby-2.0.0-p247")
        end

        it "still gets the correct pre_window command" do
          expect(project.pre_window).to eq "rvm use ruby-2.0.0-p247"
        end
      end

      context "pre_tab is present" do
        before do
          allow(project).to receive_messages(rbenv?: false)
          allow(project).to receive_messages(pre_tab?: true)
        end

        it "still gets the correct pre_window command" do
          expect(project.pre_window).to be_nil
        end
      end
    end
  end

  describe "#socket" do
    context "socket path is present" do
      before do
        allow(project).to receive_messages(socket_path: "/tmp")
      end

      it "gets the socket path" do
        expect(project.socket).to eq " -S /tmp"
      end
    end
  end

  describe "#tmux_command" do
    context "tmux_command specified" do
      before do
        project.yaml["tmux_command"] = "byobu"
      end

      it "gets the custom tmux command" do
        expect(project.tmux_command).to eq "byobu"
      end
    end

    context "tmux_command is not specified" do
      it "returns the default" do
        expect(project.tmux_command).to eq "tmux"
      end
    end
  end

  describe "#tmux_options" do
    context "no tmux options" do
      before do
        allow(project).to receive_messages(tmux_options?: false)
      end

      it "returns nothing" do
        expect(project.tmux_options).to eq ""
      end
    end

    context "with deprecations" do
      before do
        allow(project_with_deprecations).to receive_messages(cli_args?: true)
      end

      it "still gets the tmux options" do
        expect(project_with_deprecations.tmux_options).to \
          eq " -f ~/.tmux.mac.conf"
      end
    end
  end

  describe "#get_pane_base_index" do
    it "extracts pane-base-index from the global tmux window options" do
      allow_any_instance_of(Kernel).to receive(:`).
        with(Regexp.new("tmux.+ show-window-option -g pane-base-index")).
        and_return("pane-base-index 3\n")

      expect(project.get_pane_base_index).to eq("3")
    end
  end

  describe "#get_base_index" do
    it "extracts base-index from the global tmux options" do
      allow_any_instance_of(Kernel).to receive(:`).
        with(Regexp.new("tmux.+ show-option -g base-index")).
        and_return("base-index 1\n")

      expect(project.get_base_index).to eq("1")
    end
  end

  describe "#base_index" do
    context "when pane_base_index is 1 and base_index is unset" do
      before do
        allow(project).to receive_messages(get_pane_base_index: "1")
        allow(project).to receive_messages(get_base_index: nil)
      end

      it "gets the tmux default of 0" do
        expect(project.base_index).to eq(0)
      end
    end

    context "base index present" do
      before do
        allow(project).to receive_messages(get_base_index: "1")
      end

      it "gets the base index" do
        expect(project.base_index).to eq 1
      end
    end

    context "base index not present" do
      before do
        allow(project).to receive_messages(get_base_index: nil)
      end

      it "defaults to 0" do
        expect(project.base_index).to eq 0
      end
    end
  end

  describe "#startup_window" do
    context "startup window specified" do
      it "gets the startup window from project config" do
        project.yaml["startup_window"] = "logs"

        expect(project.startup_window).to eq("sample:logs")
      end
    end

    context "startup window not specified" do
      it "returns base index instead" do
        allow(project).to receive_messages(base_index: 8)

        expect(project.startup_window).to eq("sample:8")
      end
    end
  end

  describe "#startup_pane" do
    context "startup pane specified" do
      it "get the startup pane index from project config" do
        project.yaml["startup_pane"] = 1

        expect(project.startup_pane).to eq("sample:0.1")
      end
    end

    context "startup pane not specified" do
      it "returns the base pane instead" do
        allow(project).to receive_messages(pane_base_index: 4)

        expect(project.startup_pane).to eq("sample:0.4")
      end
    end
  end

  describe "#window" do
    it "gets the window and index for tmux" do
      expect(project.window(1)).to eq "sample:1"
    end
  end

  describe "#name?" do
    context "name is present" do
      it "returns true" do
        expect(project.name?).to be_truthy
      end
    end
  end

  describe "#windows?" do
    context "windows are present" do
      it "returns true" do
        expect(project.windows?).to be_truthy
      end
    end
  end

  describe "#root?" do
    context "root are present" do
      it "returns true" do
        expect(project.root?).to be_truthy
      end
    end
  end

  describe "#send_keys" do
    context "no command for window" do
      it "returns empty string" do
        expect(project.send_keys("", 1)).to be_empty
      end
    end

    context "command for window is not empty" do
      it "returns the tmux command" do
        expect(project.send_keys("vim", 1)).to \
          eq "tmux -f ~/.tmux.mac.conf -L foo send-keys -t sample:1 vim C-m"
      end
    end
  end

  describe "#send_pane_command" do
    context "no command for pane" do
      it "returns empty string" do
        expect(project.send_pane_command("", 0, 0)).to be_empty
      end
    end

    context "command for pane is not empty" do
      it "returns the tmux command" do
        expect(project.send_pane_command("vim", 1, 0)).to \
          eq "tmux -f ~/.tmux.mac.conf -L foo send-keys -t sample:1 vim C-m"
      end
    end
  end

  describe "#deprecations" do
    context "without deprecations" do
      it "is empty" do
        expect(project.deprecations).to be_empty
      end
    end

    context "with deprecations" do
      it "is not empty" do
        expect(project_with_deprecations.deprecations).to_not be_empty
      end
    end
  end

  describe "#commands" do
    let(:window) { project.windows.keep_if { |w| w.name == "shell" }.first }

    it "splits commands into an array" do
      commands = [
        "tmux -f ~/.tmux.mac.conf -L foo send-keys -t sample:1 git\\ pull C-m",
        "tmux -f ~/.tmux.mac.conf -L foo send-keys -t sample:1 git\\ merge C-m"
      ]
      expect(window.commands).to eq(commands)
    end
  end

  describe "#pre" do
    subject(:pre) { project.pre }

    context "pre in yaml is string" do
      before { project.yaml["pre"] = "mysql.server start" }

      it "returns the string" do
        expect(pre).to eq("mysql.server start")
      end
    end

    context "pre in yaml is Array" do
      before do
        project.yaml["pre"] = [
          "mysql.server start",
          "memcached -d"
        ]
      end

      it "joins array using ;" do
        expect(pre).to eq("mysql.server start; memcached -d")
      end
    end
  end

  describe "#attach?" do
    context "attach is true in yaml" do
      before { project.yaml["attach"] = true }

      it "returns true" do
        expect(project.attach?).to be_truthy
      end
    end

    context "attach is not defined in yaml" do
      it "returns true" do
        expect(project.attach?).to be_truthy
      end
    end

    context "attach is false in yaml" do
      before { project.yaml["attach"] = false }
      it "returns false" do
        expect(project.attach?).to be_falsey
      end
    end

    context "attach is true in yaml, but command line forces detach" do
      before { project_with_force_attach.yaml["attach"] = true }

      it "returns false" do
        expect(project_with_force_detach.attach?).to be_falsey
      end
    end

    context "attach is false in yaml, but command line forces attach" do
      before { project_with_force_detach.yaml["attach"] = false }

      it "returns true" do
        expect(project_with_force_attach.attach?).to be_truthy
      end
    end
  end

  describe "tmux_new_session_command" do
    let(:command) { "#{executable} new-session -d -s #{session} -n #{window}" }
    let(:executable) { project.tmux }
    let(:session) { project.name }
    let(:window) { project.windows.first.name }

    context "when first window has a name" do
      it "returns command to start a new detached session" do
        expect(project.tmux_new_session_command).to eq command
      end
    end

    context "when first window is nameless" do
      let(:project) { nameless_window_project }
      let(:command) { "#{project.tmux} new-session -d -s #{project.name} " }

      it "returns command to for new detached session without a window name" do
        expect(project.tmux_new_session_command).to eq command
      end
    end
  end

  describe "tmux_kill_session_command" do
    let(:command) { "#{executable} kill-session -t #{session}" }
    let(:executable) { project.tmux }
    let(:session) { project.name }

    context "when first window has a name" do
      it "returns command to start a new detached session" do
        expect(project.tmux_kill_session_command).to eq command
      end
    end
  end

  describe "::load" do
    let(:path) { File.expand_path("../../fixtures/sample.yml", __dir__) }
    let(:options) { {} }

    it "should raise if the project file doesn't parse" do
      bad_yaml = <<-Y
      name: "foo"
        subkey:
      Y
      expect(File).to receive(:read).with(path) { bad_yaml }
      expect do
        described_class.load(path, options)
      end.to raise_error RuntimeError, /\AFailed to parse config file: .+\z/
    end

    it "should return an instance of the class if the file loads" do
      expect(described_class.load(path, options)).to be_a Tmuxinator::Project
    end
  end

  describe "::parse_settings" do
    let(:args) { ["one", "two=three"] }

    it "returns settings in a hash" do
      expect(described_class.parse_settings(args)["two"]).to eq("three")
    end

    it "removes settings from args" do
      described_class.parse_settings(args)
      expect(args).to eq(["one"])
    end
  end

  describe "#validate!" do
    it "should raise if there are no windows defined" do
      nowindows_project = FactoryBot.build(:nowindows_project)
      expect do
        nowindows_project.validate!
      end.to raise_error RuntimeError, %r{should.include.some.windows}
    end

    it "should raise if there is not a project name" do
      expect do
        noname_project.validate!
      end.to raise_error RuntimeError, %r{didn't.specify.a.'project_name'}
    end
  end

  describe "#pane_titles" do
    before do
      allow(project).to receive(:tmux).and_return "tmux"
    end

    context "pane_titles not enabled" do
      before { project.yaml["enable_pane_titles"] = false }

      it "returns false" do
        expect(project.enable_pane_titles?).to be false
      end
    end

    context "pane_titles enabled" do
      before { project.yaml["enable_pane_titles"] = true }

      it "returns true" do
        expect(project.enable_pane_titles?).to be true
      end
    end

    context "pane_title_position not configured" do
      before { project.yaml["pane_title_position"] = nil }

      it "configures a default position of top" do
        expect(project.tmux_set_pane_title_position("x")).to eq(
          "tmux set-window-option -t x pane-border-status top"
        )
      end
    end

    context "pane_title_position configured" do
      before { project.yaml["pane_title_position"] = "bottom" }

      it "configures a position of bottom" do
        expect(project.tmux_set_pane_title_position("x")).to eq(
          "tmux set-window-option -t x pane-border-status bottom"
        )
      end
    end

    context "pane_title_position invalid" do
      before { project.yaml["pane_title_position"] = "other" }

      it "configures the default position" do
        expect(project.tmux_set_pane_title_position("x")).to eq(
          "tmux set-window-option -t x pane-border-status top"
        )
      end
    end

    context "pane_title_format not configured" do
      before { project.yaml["pane_title_format"] = nil }

      it "configures a default format" do
        resp = ""\
          "tmux set-window-option -t x pane-border-format"\
          " \"\#{pane_index}: \#{pane_title}\""
        expect(project.tmux_set_pane_title_format("x")).to eq(resp)
      end
    end

    context "pane_title_format configured" do
      before { project.yaml["pane_title_format"] = " [ #T ] " }

      it "configures the provided format" do
        expect(project.tmux_set_pane_title_format("x")).to eq(
          'tmux set-window-option -t x pane-border-format " [ #T ] "'
        )
      end
    end
  end
end
