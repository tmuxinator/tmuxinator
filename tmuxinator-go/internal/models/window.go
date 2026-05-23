// Package models defines the core data structures for tmuxinator projects.
package models

import (
	"path/filepath"

	"github.com/tmuxinator/tmuxinator/internal/util"
)

// Window represents a single tmux window within a project.
type Window struct {
	Index    int
	Name     string   // shell-escaped window name
	RawName  string   // unescaped window name
	Layout   string   // tmux layout name (shell-escaped)
	Panes    []*Pane
	Commands []string // commands when no panes are defined
	Project  *Project

	// Synchronize panes: "", "before", "after", or "true" (legacy = "before")
	Synchronize string

	// Window-level root (overrides project root)
	windowRoot string

	// Window-level pre command
	pre string

	// Focused pane config (name or index)
	focusedPaneConfig string
}

// Root returns the effective root path for this window (shell-escaped).
// If the window has its own root, it is joined with the project root.
func (w *Window) Root() string {
	if w.windowRoot == "" {
		if w.Project.Root() != "" {
			return w.Project.Root()
		}
		return ""
	}
	projectRoot := ""
	if w.Project.Root() != "" {
		// Unescape the project root for path joining
		projectRoot = util.ExpandHome(w.Project.Root())
	}
	expanded := util.AbsPath(filepath.Join(projectRoot, w.windowRoot))
	return util.ShellEscape(expanded)
}

// HasRoot returns true if this window has an effective root path.
func (w *Window) HasRoot() bool {
	return w.Root() != ""
}

// Pre returns the window-level pre command (joined if array).
func (w *Window) Pre() string {
	return w.pre
}

// TmuxWindowTarget returns the tmux target "session:windowIndex".
func (w *Window) TmuxWindowTarget() string {
	return w.Project.Name() + ":" + itoa(w.Index+w.Project.BaseIndex())
}

// TmuxPreWindowCommand returns the send-keys command for the project pre_window.
func (w *Window) TmuxPreWindowCommand() string {
	pw := w.Project.PreWindow()
	if pw == "" {
		return ""
	}
	return w.Project.Tmux() + " send-keys -t " + w.TmuxWindowTarget() + " " + util.ShellEscape(pw) + " C-m"
}

// TmuxWindowNameOption returns the -n <name> option string, or empty string.
func (w *Window) TmuxWindowNameOption() string {
	if w.Name == "" {
		return ""
	}
	return "-n " + w.Name
}

// TmuxNewWindowCommand returns the new-window command for this window.
func (w *Window) TmuxNewWindowCommand() string {
	path := ""
	if w.HasRoot() {
		path = w.Project.DefaultPathOption() + " " + w.Root() + " "
	}
	return w.Project.Tmux() + " new-window " + path + "-k -t " + w.TmuxWindowTarget() + " " + w.TmuxWindowNameOption()
}

// TmuxTiledLayoutCommand returns the select-layout tiled command.
func (w *Window) TmuxTiledLayoutCommand() string {
	return w.Project.Tmux() + " select-layout -t " + w.TmuxWindowTarget() + " tiled"
}

// TmuxLayoutCommand returns the select-layout command for this window's layout.
func (w *Window) TmuxLayoutCommand() string {
	return w.Project.Tmux() + " select-layout -t " + w.TmuxWindowTarget() + " " + w.Layout
}

// TmuxFocusPaneCommand returns the select-pane command for the focused pane.
func (w *Window) TmuxFocusPaneCommand() string {
	return w.Project.Tmux() + " select-pane -t " + w.focusedPaneTarget()
}

// TmuxSynchronizePanes returns the set-window-option synchronize-panes on command.
func (w *Window) TmuxSynchronizePanes() string {
	return w.Project.Tmux() + " set-window-option -t " + w.TmuxWindowTarget() + " synchronize-panes on"
}

// SynchronizeBefore returns true if panes should be synchronized before commands.
func (w *Window) SynchronizeBefore() bool {
	return w.Synchronize == "before" || w.Synchronize == "true"
}

// SynchronizeAfter returns true if panes should be synchronized after commands.
func (w *Window) SynchronizeAfter() bool {
	return w.Synchronize == "after"
}

// HasPanes returns true if this window has pane definitions.
func (w *Window) HasPanes() bool {
	return len(w.Panes) > 0
}

// focusedPaneTarget returns the tmux target for the focused pane.
func (w *Window) focusedPaneTarget() string {
	paneIdx := w.focusedPaneIndex()
	return w.TmuxWindowTarget() + "." + itoa(paneIdx+w.Project.PaneBaseIndex())
}

// focusedPaneIndex returns the 0-based index of the focused pane.
func (w *Window) focusedPaneIndex() int {
	if w.focusedPaneConfig == "" {
		return 0
	}
	// Try as integer
	if n, ok := parseIntSafe(w.focusedPaneConfig); ok {
		if n >= 0 && n < len(w.Panes) {
			return n
		}
		return 0
	}
	// Try as pane title
	escaped := util.ShellEscape(w.focusedPaneConfig)
	for i, p := range w.Panes {
		if p.Title == escaped {
			return i
		}
	}
	return 0
}

