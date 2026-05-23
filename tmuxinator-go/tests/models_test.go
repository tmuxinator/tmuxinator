package tests

import (
	"os"
	"strings"
	"testing"

	"github.com/tmuxinator/tmuxinator/internal/models"
)

// makeProject is a helper that creates a Project from a YAML map.
func makeProject(yaml map[string]interface{}, opts map[string]interface{}) *models.Project {
	if opts == nil {
		opts = map[string]interface{}{}
	}
	return models.NewProject(yaml, opts)
}

// TestProjectName verifies session name generation.
func TestProjectName(t *testing.T) {
	tests := []struct {
		yaml map[string]interface{}
		opts map[string]interface{}
		want string // expected shell-escaped name (dots/colons → __)
	}{
		{
			yaml: map[string]interface{}{"name": "myproject"},
			want: "'myproject'",
		},
		{
			yaml: map[string]interface{}{"project_name": "myproject"},
			want: "'myproject'",
		},
		{
			yaml: map[string]interface{}{"name": "my.project"},
			want: "'my__project'",
		},
		{
			yaml: map[string]interface{}{"name": "my:project"},
			want: "'my__project'",
		},
		{
			yaml: map[string]interface{}{"name": "simple"},
			opts: map[string]interface{}{"custom_name": "override"},
			want: "'override'",
		},
	}

	for _, tt := range tests {
		p := makeProject(tt.yaml, tt.opts)
		got := p.Name()
		if got != tt.want {
			t.Errorf("Name() = %q, want %q (yaml=%v)", got, tt.want, tt.yaml)
		}
	}
}

// TestProjectRoot verifies root path handling.
func TestProjectRoot(t *testing.T) {
	t.Setenv("HOME", "/home/testuser")

	p := makeProject(map[string]interface{}{
		"name": "test",
		"root": "~/projects",
	}, nil)

	root := p.Root()
	if root == "" {
		t.Error("Root() should not be empty")
	}
	if !strings.Contains(root, "projects") {
		t.Errorf("Root() = %q, expected to contain 'projects'", root)
	}
}

// TestProjectNoRoot verifies that missing root returns empty string.
func TestProjectNoRoot(t *testing.T) {
	p := makeProject(map[string]interface{}{
		"name":    "test",
		"windows": []interface{}{},
	}, nil)

	if p.Root() != "" {
		t.Errorf("Root() = %q, want empty string", p.Root())
	}
	if p.HasRoot() {
		t.Error("HasRoot() should be false when no root is set")
	}
}

// TestProjectPreWindow verifies pre_window command handling.
func TestProjectPreWindow(t *testing.T) {
	p := makeProject(map[string]interface{}{
		"name":       "test",
		"pre_window": "rbenv shell 2.0.0",
	}, nil)

	if p.PreWindow() != "rbenv shell 2.0.0" {
		t.Errorf("PreWindow() = %q, want 'rbenv shell 2.0.0'", p.PreWindow())
	}
}

// TestProjectPreWindowDisabled verifies no_pre_window option.
func TestProjectPreWindowDisabled(t *testing.T) {
	p := makeProject(
		map[string]interface{}{
			"name":       "test",
			"pre_window": "rbenv shell 2.0.0",
		},
		map[string]interface{}{"no_pre_window": true},
	)

	if p.PreWindow() != "" {
		t.Errorf("PreWindow() = %q, want empty string when no_pre_window=true", p.PreWindow())
	}
}

// TestProjectHooks verifies hook parsing.
func TestProjectHooks(t *testing.T) {
	p := makeProject(map[string]interface{}{
		"name":                   "test",
		"on_project_start":       "echo start",
		"on_project_first_start": "echo first",
		"on_project_restart":     "echo restart",
		"on_project_exit":        "echo exit",
		"on_project_stop":        "echo stop",
	}, nil)

	hooks := p.Hooks()
	if hooks.OnProjectStart != "echo start" {
		t.Errorf("OnProjectStart = %q, want 'echo start'", hooks.OnProjectStart)
	}
	if hooks.OnProjectFirstStart != "echo first" {
		t.Errorf("OnProjectFirstStart = %q, want 'echo first'", hooks.OnProjectFirstStart)
	}
	if hooks.OnProjectRestart != "echo restart" {
		t.Errorf("OnProjectRestart = %q, want 'echo restart'", hooks.OnProjectRestart)
	}
	if hooks.OnProjectExit != "echo exit" {
		t.Errorf("OnProjectExit = %q, want 'echo exit'", hooks.OnProjectExit)
	}
	if hooks.OnProjectStop != "echo stop" {
		t.Errorf("OnProjectStop = %q, want 'echo stop'", hooks.OnProjectStop)
	}
}

// TestProjectHooksArray verifies that array hooks are joined with "; ".
func TestProjectHooksArray(t *testing.T) {
	p := makeProject(map[string]interface{}{
		"name": "test",
		"on_project_start": []interface{}{
			"echo one",
			"echo two",
			"echo three",
		},
	}, nil)

	hooks := p.Hooks()
	want := "echo one; echo two; echo three"
	if hooks.OnProjectStart != want {
		t.Errorf("OnProjectStart = %q, want %q", hooks.OnProjectStart, want)
	}
}

// TestProjectAttach verifies attach behavior.
func TestProjectAttach(t *testing.T) {
	// Default: attach = true
	p := makeProject(map[string]interface{}{"name": "test"}, nil)
	if !p.Attach() {
		t.Error("Attach() should default to true")
	}

	// Explicit attach: false
	p2 := makeProject(map[string]interface{}{
		"name":   "test",
		"attach": false,
	}, nil)
	if p2.Attach() {
		t.Error("Attach() should be false when yaml attach=false")
	}

	// force_attach overrides yaml
	p3 := makeProject(
		map[string]interface{}{"name": "test", "attach": false},
		map[string]interface{}{"force_attach": true},
	)
	if !p3.Attach() {
		t.Error("Attach() should be true when force_attach=true")
	}

	// force_detach overrides yaml
	p4 := makeProject(
		map[string]interface{}{"name": "test", "attach": true},
		map[string]interface{}{"force_detach": true},
	)
	if p4.Attach() {
		t.Error("Attach() should be false when force_detach=true")
	}
}

// TestProjectTmuxCommand verifies tmux command construction.
func TestProjectTmuxCommand(t *testing.T) {
	// Default
	p := makeProject(map[string]interface{}{"name": "test"}, nil)
	if p.TmuxCommand() != "tmux" {
		t.Errorf("TmuxCommand() = %q, want 'tmux'", p.TmuxCommand())
	}

	// Custom command
	p2 := makeProject(map[string]interface{}{
		"name":         "test",
		"tmux_command": "byobu",
	}, nil)
	if p2.TmuxCommand() != "byobu" {
		t.Errorf("TmuxCommand() = %q, want 'byobu'", p2.TmuxCommand())
	}
}

// TestProjectTmuxOptions verifies tmux options construction.
func TestProjectTmuxOptions(t *testing.T) {
	p := makeProject(map[string]interface{}{
		"name":         "test",
		"tmux_options": "-f ~/.tmux.conf",
	}, nil)

	if p.TmuxOptions() != " -f ~/.tmux.conf" {
		t.Errorf("TmuxOptions() = %q, want ' -f ~/.tmux.conf'", p.TmuxOptions())
	}
}

// TestProjectSocket verifies socket configuration.
func TestProjectSocket(t *testing.T) {
	// Socket name
	p := makeProject(map[string]interface{}{
		"name":        "test",
		"socket_name": "foo",
	}, nil)
	if p.Socket() != " -L foo" {
		t.Errorf("Socket() = %q, want ' -L foo'", p.Socket())
	}

	// Socket path
	p2 := makeProject(map[string]interface{}{
		"name":        "test",
		"socket_path": "/tmp/tmux.sock",
	}, nil)
	if p2.Socket() != " -S /tmp/tmux.sock" {
		t.Errorf("Socket() = %q, want ' -S /tmp/tmux.sock'", p2.Socket())
	}
}

// TestProjectDeprecations verifies deprecation detection.
func TestProjectDeprecations(t *testing.T) {
	p := makeProject(map[string]interface{}{
		"name":      "test",
		"cli_args":  "-f ~/.tmux.conf",
		"pre":       "echo pre",
		"post":      "echo post",
		"windows":   []interface{}{},
	}, nil)

	deps := p.Deprecations()
	if len(deps) == 0 {
		t.Error("expected deprecation warnings for cli_args, pre, post")
	}

	// Check that cli_args deprecation is present
	found := false
	for _, d := range deps {
		if strings.Contains(d, "cli_args") {
			found = true
			break
		}
	}
	if !found {
		t.Error("expected cli_args deprecation warning")
	}
}

// TestProjectWindows verifies window parsing.
func TestProjectWindows(t *testing.T) {
	p := makeProject(map[string]interface{}{
		"name": "test",
		"windows": []interface{}{
			map[string]interface{}{"editor": "vim"},
			map[string]interface{}{"server": "rails s"},
			map[string]interface{}{"logs": "tail -f log/development.log"},
		},
	}, nil)

	windows := p.Windows()
	if len(windows) != 3 {
		t.Fatalf("got %d windows, want 3", len(windows))
	}

	if windows[0].RawName != "editor" {
		t.Errorf("windows[0].RawName = %q, want 'editor'", windows[0].RawName)
	}
	if windows[1].RawName != "server" {
		t.Errorf("windows[1].RawName = %q, want 'server'", windows[1].RawName)
	}
}

// TestProjectValidate verifies project validation.
func TestProjectValidate(t *testing.T) {
	// Valid project
	p := makeProject(map[string]interface{}{
		"name": "test",
		"windows": []interface{}{
			map[string]interface{}{"editor": "vim"},
		},
	}, nil)
	if err := p.Validate(); err != nil {
		t.Errorf("Validate() returned error for valid project: %v", err)
	}

	// No windows
	p2 := makeProject(map[string]interface{}{
		"name":    "test",
		"windows": []interface{}{},
	}, nil)
	if err := p2.Validate(); err == nil {
		t.Error("Validate() should return error when no windows")
	}

	// No name
	p3 := makeProject(map[string]interface{}{
		"windows": []interface{}{
			map[string]interface{}{"editor": "vim"},
		},
	}, nil)
	if err := p3.Validate(); err == nil {
		t.Error("Validate() should return error when no name")
	}
}

// TestParseHookField verifies hook field parsing.
func TestParseHookField(t *testing.T) {
	// String
	if got := models.ParseHookField("echo hello"); got != "echo hello" {
		t.Errorf("ParseHookField(string) = %q, want 'echo hello'", got)
	}

	// Array
	arr := []interface{}{"echo one", "echo two"}
	if got := models.ParseHookField(arr); got != "echo one; echo two" {
		t.Errorf("ParseHookField(array) = %q, want 'echo one; echo two'", got)
	}

	// Nil
	if got := models.ParseHookField(nil); got != "" {
		t.Errorf("ParseHookField(nil) = %q, want ''", got)
	}
}

// TestWindowTmuxWindowTarget verifies window target string generation.
func TestWindowTmuxWindowTarget(t *testing.T) {
	p := makeProject(map[string]interface{}{
		"name": "myproject",
		"windows": []interface{}{
			map[string]interface{}{"editor": "vim"},
		},
	}, nil)

	windows := p.Windows()
	if len(windows) == 0 {
		t.Fatal("no windows")
	}

	// With base-index 0 (default), first window target should be "myproject:0"
	// Note: Name() returns shell-escaped value
	target := windows[0].TmuxWindowTarget()
	if !strings.Contains(target, "myproject") {
		t.Errorf("TmuxWindowTarget() = %q, expected to contain 'myproject'", target)
	}
}

// TestWindowPanes verifies pane creation within windows.
func TestWindowPanes(t *testing.T) {
	p := makeProject(map[string]interface{}{
		"name": "test",
		"windows": []interface{}{
			map[string]interface{}{
				"editor": map[string]interface{}{
					"layout": "main-vertical",
					"panes": []interface{}{
						"vim",
						nil,
						"top",
					},
				},
			},
		},
	}, nil)

	windows := p.Windows()
	if len(windows) != 1 {
		t.Fatalf("got %d windows, want 1", len(windows))
	}

	panes := windows[0].Panes
	if len(panes) != 3 {
		t.Errorf("got %d panes, want 3", len(panes))
	}

	// First pane has "vim" command
	if len(panes[0].Commands) != 1 || panes[0].Commands[0] != "vim" {
		t.Errorf("panes[0].Commands = %v, want ['vim']", panes[0].Commands)
	}

	// Second pane is empty
	if len(panes[1].Commands) != 0 {
		t.Errorf("panes[1].Commands = %v, want []", panes[1].Commands)
	}

	// Last pane
	if !panes[2].IsLast() {
		t.Error("panes[2].IsLast() should be true")
	}
	if panes[0].IsLast() {
		t.Error("panes[0].IsLast() should be false")
	}
}

// TestWindowSynchronize verifies synchronize option parsing.
func TestWindowSynchronize(t *testing.T) {
	p := makeProject(map[string]interface{}{
		"name": "test",
		"windows": []interface{}{
			map[string]interface{}{
				"sync_before": map[string]interface{}{
					"synchronize": "before",
					"panes":       []interface{}{"vim"},
				},
			},
			map[string]interface{}{
				"sync_after": map[string]interface{}{
					"synchronize": "after",
					"panes":       []interface{}{"vim"},
				},
			},
		},
	}, nil)

	windows := p.Windows()
	if len(windows) != 2 {
		t.Fatalf("got %d windows, want 2", len(windows))
	}

	if !windows[0].SynchronizeBefore() {
		t.Error("windows[0].SynchronizeBefore() should be true")
	}
	if windows[0].SynchronizeAfter() {
		t.Error("windows[0].SynchronizeAfter() should be false")
	}
	if !windows[1].SynchronizeAfter() {
		t.Error("windows[1].SynchronizeAfter() should be true")
	}
}

// TestPaneTmuxCommands verifies pane command generation.
func TestPaneTmuxCommands(t *testing.T) {
	p := makeProject(map[string]interface{}{
		"name": "myproject",
		"windows": []interface{}{
			map[string]interface{}{
				"editor": map[string]interface{}{
					"panes": []interface{}{
						"vim",
						"guard",
					},
				},
			},
		},
	}, nil)

	windows := p.Windows()
	panes := windows[0].Panes

	// TmuxMainCommand should include send-keys
	cmd := panes[0].TmuxMainCommand("vim")
	if !strings.Contains(cmd, "send-keys") {
		t.Errorf("TmuxMainCommand() = %q, expected 'send-keys'", cmd)
	}
	if !strings.Contains(cmd, "vim") {
		t.Errorf("TmuxMainCommand() = %q, expected 'vim'", cmd)
	}

	// TmuxSplitCommand should include splitw
	splitCmd := panes[0].TmuxSplitCommand()
	if !strings.Contains(splitCmd, "splitw") {
		t.Errorf("TmuxSplitCommand() = %q, expected 'splitw'", splitCmd)
	}
}

// TestProjectNewSessionCommand verifies new-session command generation.
func TestProjectNewSessionCommand(t *testing.T) {
	p := makeProject(map[string]interface{}{
		"name": "myproject",
		"windows": []interface{}{
			map[string]interface{}{"editor": "vim"},
		},
	}, nil)

	cmd := p.TmuxNewSessionCommand()
	if !strings.Contains(cmd, "new-session") {
		t.Errorf("TmuxNewSessionCommand() = %q, expected 'new-session'", cmd)
	}
	if !strings.Contains(cmd, "myproject") {
		t.Errorf("TmuxNewSessionCommand() = %q, expected 'myproject'", cmd)
	}
}

// TestProjectKillSessionCommand verifies kill-session command generation.
func TestProjectKillSessionCommand(t *testing.T) {
	p := makeProject(map[string]interface{}{
		"name": "myproject",
		"windows": []interface{}{
			map[string]interface{}{"editor": "vim"},
		},
	}, nil)

	cmd := p.TmuxKillSessionCommand()
	if !strings.Contains(cmd, "kill-session") {
		t.Errorf("TmuxKillSessionCommand() = %q, expected 'kill-session'", cmd)
	}
}

// TestProjectPreAndPost verifies pre/post command handling.
func TestProjectPreAndPost(t *testing.T) {
	p := makeProject(map[string]interface{}{
		"name":    "test",
		"pre":     "echo pre",
		"post":    "echo post",
		"windows": []interface{}{},
	}, nil)

	if p.Pre() != "echo pre" {
		t.Errorf("Pre() = %q, want 'echo pre'", p.Pre())
	}
	if p.Post() != "echo post" {
		t.Errorf("Post() = %q, want 'echo post'", p.Post())
	}
}

// TestProjectPreArray verifies that array pre commands are joined.
func TestProjectPreArray(t *testing.T) {
	p := makeProject(map[string]interface{}{
		"name": "test",
		"pre": []interface{}{
			"echo one",
			"echo two",
		},
		"windows": []interface{}{},
	}, nil)

	want := "echo one; echo two"
	if p.Pre() != want {
		t.Errorf("Pre() = %q, want %q", p.Pre(), want)
	}
}

// Ensure os is used.
var _ = os.Getenv

