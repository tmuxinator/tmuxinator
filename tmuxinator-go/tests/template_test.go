package tests

import (
	"os"
	"strings"
	"testing"

	"github.com/tmuxinator/tmuxinator/internal/config"
	"github.com/tmuxinator/tmuxinator/internal/template"
)

// TestRenderStartBasic verifies that RenderStart produces a valid shell script.
func TestRenderStartBasic(t *testing.T) {
	yaml := `
name: myproject
root: /tmp
windows:
  - editor: vim
  - server: bundle exec rails s
`
	f, err := os.CreateTemp("", "tmuxinator-tmpl-*.yml")
	if err != nil {
		t.Fatal(err)
	}
	defer os.Remove(f.Name())
	f.WriteString(yaml)
	f.Close()

	project, err := config.LoadProject(f.Name(), map[string]interface{}{
		"force_detach": true,
	})
	if err != nil {
		t.Fatalf("LoadProject failed: %v", err)
	}

	script, err := template.RenderStart(project)
	if err != nil {
		t.Fatalf("RenderStart failed: %v", err)
	}

	// Script should start with a shebang
	if !strings.HasPrefix(script, "#!") {
		preview := script
		if len(preview) > 50 {
			preview = preview[:50]
		}
		t.Errorf("script should start with shebang, got: %q", preview)
	}

	// Should contain new-session
	if !strings.Contains(script, "new-session") {
		t.Errorf("script should contain 'new-session'")
	}

	// Should contain the project name
	if !strings.Contains(script, "myproject") {
		t.Errorf("script should contain 'myproject'")
	}

	// Should contain new-window for each window
	count := strings.Count(script, "new-window")
	if count < 2 {
		t.Errorf("script should contain at least 2 'new-window' commands, got %d", count)
	}
}

// TestRenderStartWithPanes verifies pane commands in the generated script.
func TestRenderStartWithPanes(t *testing.T) {
	yaml := `
name: panetest
root: /tmp
windows:
  - editor:
      layout: main-vertical
      panes:
        - vim
        - guard
`
	f, err := os.CreateTemp("", "tmuxinator-tmpl-*.yml")
	if err != nil {
		t.Fatal(err)
	}
	defer os.Remove(f.Name())
	f.WriteString(yaml)
	f.Close()

	project, err := config.LoadProject(f.Name(), map[string]interface{}{
		"force_detach": true,
	})
	if err != nil {
		t.Fatalf("LoadProject failed: %v", err)
	}

	script, err := template.RenderStart(project)
	if err != nil {
		t.Fatalf("RenderStart failed: %v", err)
	}

	// Should contain splitw for pane splitting
	if !strings.Contains(script, "splitw") {
		t.Errorf("script should contain 'splitw' for pane splitting")
	}

	// Should contain select-layout
	if !strings.Contains(script, "select-layout") {
		t.Errorf("script should contain 'select-layout'")
	}

	// Should contain send-keys for vim
	if !strings.Contains(script, "vim") {
		t.Errorf("script should contain 'vim' command")
	}
}

// TestRenderStartWithHooks verifies hook commands in the generated script.
func TestRenderStartWithHooks(t *testing.T) {
	yaml := `
name: hooktest
root: /tmp
on_project_start: echo "project started"
on_project_first_start: echo "first start"
on_project_exit: echo "project exit"
windows:
  - editor: vim
`
	f, err := os.CreateTemp("", "tmuxinator-tmpl-*.yml")
	if err != nil {
		t.Fatal(err)
	}
	defer os.Remove(f.Name())
	f.WriteString(yaml)
	f.Close()

	project, err := config.LoadProject(f.Name(), map[string]interface{}{
		"force_detach": true,
	})
	if err != nil {
		t.Fatalf("LoadProject failed: %v", err)
	}

	script, err := template.RenderStart(project)
	if err != nil {
		t.Fatalf("RenderStart failed: %v", err)
	}

	if !strings.Contains(script, "project started") {
		t.Errorf("script should contain on_project_start hook")
	}
	if !strings.Contains(script, "first start") {
		t.Errorf("script should contain on_project_first_start hook")
	}
	if !strings.Contains(script, "project exit") {
		t.Errorf("script should contain on_project_exit hook")
	}
}

// TestRenderStartWithPreWindow verifies pre_window commands.
func TestRenderStartWithPreWindow(t *testing.T) {
	yaml := `
name: prewindowtest
root: /tmp
pre_window: rbenv shell 2.0.0
windows:
  - editor:
      panes:
        - vim
        - guard
`
	f, err := os.CreateTemp("", "tmuxinator-tmpl-*.yml")
	if err != nil {
		t.Fatal(err)
	}
	defer os.Remove(f.Name())
	f.WriteString(yaml)
	f.Close()

	project, err := config.LoadProject(f.Name(), map[string]interface{}{
		"force_detach": true,
	})
	if err != nil {
		t.Fatalf("LoadProject failed: %v", err)
	}

	script, err := template.RenderStart(project)
	if err != nil {
		t.Fatalf("RenderStart failed: %v", err)
	}

	if !strings.Contains(script, "rbenv shell 2.0.0") {
		t.Errorf("script should contain pre_window command 'rbenv shell 2.0.0'")
	}
}

// TestRenderStopBasic verifies that RenderStop produces a valid stop script.
func TestRenderStopBasic(t *testing.T) {
	yaml := `
name: myproject
root: /tmp
windows:
  - editor: vim
`
	f, err := os.CreateTemp("", "tmuxinator-tmpl-*.yml")
	if err != nil {
		t.Fatal(err)
	}
	defer os.Remove(f.Name())
	f.WriteString(yaml)
	f.Close()

	project, err := config.LoadProject(f.Name(), map[string]interface{}{})
	if err != nil {
		t.Fatalf("LoadProject failed: %v", err)
	}

	script, err := template.RenderStop(project)
	if err != nil {
		t.Fatalf("RenderStop failed: %v", err)
	}

	// Script should start with a shebang
	if !strings.HasPrefix(script, "#!") {
		t.Errorf("stop script should start with shebang")
	}
}

// TestRenderStartAttach verifies attach logic in generated script.
func TestRenderStartAttach(t *testing.T) {
	yaml := `
name: attachtest
root: /tmp
attach: true
windows:
  - editor: vim
`
	f, err := os.CreateTemp("", "tmuxinator-tmpl-*.yml")
	if err != nil {
		t.Fatal(err)
	}
	defer os.Remove(f.Name())
	f.WriteString(yaml)
	f.Close()

	project, err := config.LoadProject(f.Name(), map[string]interface{}{})
	if err != nil {
		t.Fatalf("LoadProject failed: %v", err)
	}

	script, err := template.RenderStart(project)
	if err != nil {
		t.Fatalf("RenderStart failed: %v", err)
	}

	// Should contain attach-session
	if !strings.Contains(script, "attach-session") {
		t.Errorf("script should contain 'attach-session' when attach=true")
	}
}

// TestRenderStartNoAttach verifies no attach when force_detach is set.
func TestRenderStartNoAttach(t *testing.T) {
	yaml := `
name: noattachtest
root: /tmp
windows:
  - editor: vim
`
	f, err := os.CreateTemp("", "tmuxinator-tmpl-*.yml")
	if err != nil {
		t.Fatal(err)
	}
	defer os.Remove(f.Name())
	f.WriteString(yaml)
	f.Close()

	project, err := config.LoadProject(f.Name(), map[string]interface{}{
		"force_detach": true,
	})
	if err != nil {
		t.Fatalf("LoadProject failed: %v", err)
	}

	script, err := template.RenderStart(project)
	if err != nil {
		t.Fatalf("RenderStart failed: %v", err)
	}

	// Should NOT contain attach-session
	if strings.Contains(script, "attach-session") {
		t.Errorf("script should not contain 'attach-session' when force_detach=true")
	}
}

// TestRenderStartWindowCommands verifies window-level commands (no panes).
func TestRenderStartWindowCommands(t *testing.T) {
	yaml := `
name: cmdtest
root: /tmp
windows:
  - server: bundle exec rails s
  - logs: tail -f log/development.log
`
	f, err := os.CreateTemp("", "tmuxinator-tmpl-*.yml")
	if err != nil {
		t.Fatal(err)
	}
	defer os.Remove(f.Name())
	f.WriteString(yaml)
	f.Close()

	project, err := config.LoadProject(f.Name(), map[string]interface{}{
		"force_detach": true,
	})
	if err != nil {
		t.Fatalf("LoadProject failed: %v", err)
	}

	script, err := template.RenderStart(project)
	if err != nil {
		t.Fatalf("RenderStart failed: %v", err)
	}

	if !strings.Contains(script, "bundle exec rails s") {
		t.Errorf("script should contain 'bundle exec rails s'")
	}
	if !strings.Contains(script, "tail -f log/development.log") {
		t.Errorf("script should contain 'tail -f log/development.log'")
	}
}

