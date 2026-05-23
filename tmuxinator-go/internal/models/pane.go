// Package models defines the core data structures for tmuxinator projects.
package models

import (
	"github.com/tmuxinator/tmuxinator/internal/util"
)

// Pane represents a single tmux pane within a window.
type Pane struct {
	Index    int
	Commands []string // commands to send to this pane
	Title    string   // optional pane title (tmux >= 2.6)
	Window   *Window
	Project  *Project
}

// WindowIndex returns the tmux window index for this pane's window.
func (p *Pane) WindowIndex() int {
	return p.Window.Index + p.Project.BaseIndex()
}

// PaneIndex returns the tmux pane index (adjusted for pane-base-index).
func (p *Pane) PaneIndex() int {
	return p.Index + p.Project.PaneBaseIndex()
}

// TmuxWindowAndPaneTarget returns the tmux target string "session:window.pane".
func (p *Pane) TmuxWindowAndPaneTarget() string {
	return p.Project.Name() + ":" + itoa(p.WindowIndex()) + "." + itoa(p.PaneIndex())
}

// TmuxPreWindowCommand returns the send-keys command for the project pre_window.
func (p *Pane) TmuxPreWindowCommand() string {
	pw := p.Project.PreWindow()
	if pw == "" {
		return ""
	}
	return p.Project.Tmux() + " send-keys -t " + p.TmuxWindowAndPaneTarget() + " " + util.ShellEscape(pw) + " C-m"
}

// TmuxPreCommand returns the send-keys command for the window-level pre.
func (p *Pane) TmuxPreCommand() string {
	pre := p.Window.Pre()
	if pre == "" {
		return ""
	}
	return p.Project.Tmux() + " send-keys -t " + p.TmuxWindowAndPaneTarget() + " " + util.ShellEscape(pre) + " C-m"
}

// TmuxMainCommand returns the send-keys command for a pane command.
func (p *Pane) TmuxMainCommand(command string) string {
	if command == "" {
		return ""
	}
	return p.Project.Tmux() + " send-keys -t " + p.TmuxWindowAndPaneTarget() + " " + util.ShellEscape(command) + " C-m"
}

// TmuxSetTitle returns the select-pane -T command to set the pane title.
func (p *Pane) TmuxSetTitle() string {
	if p.Title == "" {
		return ""
	}
	return p.Project.Tmux() + " select-pane -t " + p.TmuxWindowAndPaneTarget() + " -T " + p.Title
}

// TmuxSplitCommand returns the splitw command to create this pane.
func (p *Pane) TmuxSplitCommand() string {
	path := ""
	if p.Window.Root() != "" {
		path = p.Project.DefaultPathOption() + " " + p.Window.Root() + " "
	}
	return p.Project.Tmux() + " splitw " + path + "-t " + p.Window.TmuxWindowTarget()
}

// IsLast returns true if this is the last pane in its window.
func (p *Pane) IsLast() bool {
	return p.Index == len(p.Window.Panes)-1
}

