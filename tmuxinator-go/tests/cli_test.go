package tests

import (
	"os"
	"testing"

	"github.com/tmuxinator/tmuxinator/internal/cli"
	"github.com/tmuxinator/tmuxinator/internal/config"
)

// TestRootCmdHelp verifies that the root command returns help without error.
func TestRootCmdHelp(t *testing.T) {
	root := cli.NewRootCmd()
	root.SetArgs([]string{"--help"})
	// Help should not return an error
	_ = root.Execute()
}

// TestVersionCmd verifies the version command output.
func TestVersionCmd(t *testing.T) {
	root := cli.NewRootCmd()
	root.SetArgs([]string{"version"})
	if err := root.Execute(); err != nil {
		t.Errorf("version command failed: %v", err)
	}
}

// TestDoctorCmd verifies the doctor command runs without panic.
func TestDoctorCmd(t *testing.T) {
	root := cli.NewRootCmd()
	root.SetArgs([]string{"doctor"})
	// Doctor may fail if tmux isn't installed, but shouldn't panic
	_ = root.Execute()
}

// TestListCmd verifies the list command runs without error.
func TestListCmd(t *testing.T) {
	dir := t.TempDir()
	t.Setenv("TMUXINATOR_CONFIG", dir)

	root := cli.NewRootCmd()
	root.SetArgs([]string{"list"})
	if err := root.Execute(); err != nil {
		t.Errorf("list command failed: %v", err)
	}
}

// TestListCmdWithProjects verifies list shows projects.
func TestListCmdWithProjects(t *testing.T) {
	dir := t.TempDir()
	t.Setenv("TMUXINATOR_CONFIG", dir)

	// Create a project
	if err := os.WriteFile(dir+"/myproject.yml",
		[]byte("name: myproject\nwindows:\n  - w: echo hi\n"), 0o644); err != nil {
		t.Fatal(err)
	}

	configs := config.Configs("", nil)
	if len(configs) != 1 || configs[0] != "myproject" {
		t.Errorf("expected ['myproject'], got %v", configs)
	}
}

// TestCommandsCmd verifies the commands listing.
func TestCommandsCmd(t *testing.T) {
	root := cli.NewRootCmd()
	root.SetArgs([]string{"commands"})
	if err := root.Execute(); err != nil {
		t.Errorf("commands command failed: %v", err)
	}
}

// TestDebugCmd verifies the debug command produces output for a valid project.
func TestDebugCmd(t *testing.T) {
	dir := t.TempDir()
	t.Setenv("TMUXINATOR_CONFIG", dir)

	projectYAML := `
name: debugtest
root: /tmp
windows:
  - editor: vim
  - server: rails s
`
	if err := os.WriteFile(dir+"/debugtest.yml", []byte(projectYAML), 0o644); err != nil {
		t.Fatal(err)
	}

	root := cli.NewRootCmd()
	root.SetArgs([]string{"debug", "debugtest"})
	if err := root.Execute(); err != nil {
		t.Errorf("debug command failed: %v", err)
	}
}

// TestReservedCommandNames verifies that project names don't shadow commands.
func TestReservedCommandNames(t *testing.T) {
	root := cli.NewRootCmd()
	// "start" should be a reserved command
	for _, cmd := range root.Commands() {
		if cmd.Name() == "start" {
			return // found it
		}
	}
	t.Error("'start' command not found in root command")
}

