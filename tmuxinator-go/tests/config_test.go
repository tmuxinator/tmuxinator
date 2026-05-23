package tests

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/tmuxinator/tmuxinator/internal/config"
	"github.com/tmuxinator/tmuxinator/internal/util"
)

// TestConfigDirectory verifies that Directory() returns a sensible path.
func TestConfigDirectory(t *testing.T) {
	// With TMUXINATOR_CONFIG set
	dir := t.TempDir()
	t.Setenv("TMUXINATOR_CONFIG", dir)
	got := config.Directory()
	if got != dir {
		t.Errorf("Directory() = %q, want %q", got, dir)
	}
}

// TestConfigDirectoryXDG verifies XDG config directory resolution.
func TestConfigDirectoryXDG(t *testing.T) {
	t.Setenv("TMUXINATOR_CONFIG", "")
	xdgDir := t.TempDir()
	t.Setenv("XDG_CONFIG_HOME", xdgDir)

	// Create the tmuxinator subdirectory
	tmuxDir := filepath.Join(xdgDir, "tmuxinator")
	if err := os.MkdirAll(tmuxDir, 0o755); err != nil {
		t.Fatal(err)
	}

	got := config.Directory()
	if got != tmuxDir {
		t.Errorf("Directory() = %q, want %q", got, tmuxDir)
	}
}

// TestConfigExist verifies project existence checks.
func TestConfigExist(t *testing.T) {
	dir := t.TempDir()
	t.Setenv("TMUXINATOR_CONFIG", dir)

	// Create a project file
	projectPath := filepath.Join(dir, "myproject.yml")
	if err := os.WriteFile(projectPath, []byte("name: myproject\nwindows:\n  - test: echo hi\n"), 0o644); err != nil {
		t.Fatal(err)
	}

	if !config.Exist("myproject", "") {
		t.Error("Exist('myproject') should return true")
	}
	if config.Exist("nonexistent", "") {
		t.Error("Exist('nonexistent') should return false")
	}
}

// TestConfigProject verifies project path resolution.
func TestConfigProject(t *testing.T) {
	dir := t.TempDir()
	t.Setenv("TMUXINATOR_CONFIG", dir)

	projectPath := filepath.Join(dir, "sample.yml")
	if err := os.WriteFile(projectPath, []byte("name: sample\nwindows:\n  - test: echo hi\n"), 0o644); err != nil {
		t.Fatal(err)
	}

	got := config.Project("sample")
	if got != projectPath {
		t.Errorf("Project('sample') = %q, want %q", got, projectPath)
	}
}

// TestConfigConfigs verifies the configs listing.
func TestConfigConfigs(t *testing.T) {
	dir := t.TempDir()
	t.Setenv("TMUXINATOR_CONFIG", dir)

	// Create some project files
	for _, name := range []string{"alpha.yml", "beta.yml", "gamma.yml"} {
		path := filepath.Join(dir, name)
		if err := os.WriteFile(path, []byte("name: test\nwindows:\n  - w: echo hi\n"), 0o644); err != nil {
			t.Fatal(err)
		}
	}

	configs := config.Configs("", nil)
	if len(configs) != 3 {
		t.Errorf("Configs() returned %d items, want 3: %v", len(configs), configs)
	}

	// Verify sorted order
	expected := []string{"alpha", "beta", "gamma"}
	for i, e := range expected {
		if configs[i] != e {
			t.Errorf("configs[%d] = %q, want %q", i, configs[i], e)
		}
	}
}

// TestLocalProject verifies local project detection.
func TestLocalProject(t *testing.T) {
	// Create a temp dir and change to it
	dir := t.TempDir()
	origDir, err := os.Getwd()
	if err != nil {
		t.Fatal(err)
	}
	defer os.Chdir(origDir)
	if err := os.Chdir(dir); err != nil {
		t.Fatal(err)
	}

	// No local file yet
	if config.IsLocal() {
		t.Error("IsLocal() should be false when no local file exists")
	}

	// Create local file
	localPath := filepath.Join(dir, ".tmuxinator.yml")
	if err := os.WriteFile(localPath, []byte("name: local\nwindows:\n  - w: echo hi\n"), 0o644); err != nil {
		t.Fatal(err)
	}

	if !config.IsLocal() {
		t.Error("IsLocal() should be true when .tmuxinator.yml exists")
	}
}

// TestParseSettings verifies key=value argument parsing.
func TestParseSettings(t *testing.T) {
	args := []string{"foo=bar", "baz=qux", "positional", "key=value"}
	settings, remaining := config.ParseSettings(args)

	if len(settings) != 3 {
		t.Errorf("ParseSettings: got %d settings, want 3", len(settings))
	}
	if settings["foo"] != "bar" {
		t.Errorf("settings['foo'] = %q, want 'bar'", settings["foo"])
	}
	if settings["baz"] != "qux" {
		t.Errorf("settings['baz'] = %q, want 'qux'", settings["baz"])
	}
	if settings["key"] != "value" {
		t.Errorf("settings['key'] = %q, want 'value'", settings["key"])
	}
	if len(remaining) != 1 || remaining[0] != "positional" {
		t.Errorf("remaining = %v, want ['positional']", remaining)
	}
}

// TestLoadProjectBasic verifies basic YAML project loading.
func TestLoadProjectBasic(t *testing.T) {
	content := `
name: myproject
root: /tmp
windows:
  - editor: vim
  - server: bundle exec rails s
`
	f, err := os.CreateTemp("", "tmuxinator-test-*.yml")
	if err != nil {
		t.Fatal(err)
	}
	defer os.Remove(f.Name())
	f.WriteString(content)
	f.Close()

	project, err := config.LoadProject(f.Name(), map[string]interface{}{})
	if err != nil {
		t.Fatalf("LoadProject failed: %v", err)
	}

	if project == nil {
		t.Fatal("LoadProject returned nil project")
	}

	windows := project.Windows()
	if len(windows) != 2 {
		t.Errorf("got %d windows, want 2", len(windows))
	}
}

// TestLoadProjectWithPanes verifies pane parsing.
func TestLoadProjectWithPanes(t *testing.T) {
	content := `
name: panetest
root: /tmp
windows:
  - editor:
      layout: main-vertical
      panes:
        - vim
        - guard
        - top
`
	f, err := os.CreateTemp("", "tmuxinator-test-*.yml")
	if err != nil {
		t.Fatal(err)
	}
	defer os.Remove(f.Name())
	f.WriteString(content)
	f.Close()

	project, err := config.LoadProject(f.Name(), map[string]interface{}{})
	if err != nil {
		t.Fatalf("LoadProject failed: %v", err)
	}

	windows := project.Windows()
	if len(windows) != 1 {
		t.Fatalf("got %d windows, want 1", len(windows))
	}

	panes := windows[0].Panes
	if len(panes) != 3 {
		t.Errorf("got %d panes, want 3", len(panes))
	}
}

// TestUtilExpandHome verifies home directory expansion.
func TestUtilExpandHome(t *testing.T) {
	t.Setenv("HOME", "/home/testuser")

	tests := []struct {
		input string
		want  string
	}{
		{"~/projects", "/home/testuser/projects"},
		{"~", "/home/testuser"},
		{"/absolute/path", "/absolute/path"},
		{"relative/path", "relative/path"},
		{"", ""},
	}

	for _, tt := range tests {
		got := util.ExpandHome(tt.input)
		if got != tt.want {
			t.Errorf("ExpandHome(%q) = %q, want %q", tt.input, got, tt.want)
		}
	}
}

// TestUtilShellEscape verifies shell escaping.
func TestUtilShellEscape(t *testing.T) {
	tests := []struct {
		input string
		want  string
	}{
		{"simple", "'simple'"},
		{"with space", "'with space'"},
		{"it's", `'it'\''s'`},
		{"", "''"},
	}

	for _, tt := range tests {
		got := util.ShellEscape(tt.input)
		if got != tt.want {
			t.Errorf("ShellEscape(%q) = %q, want %q", tt.input, got, tt.want)
		}
	}
}

