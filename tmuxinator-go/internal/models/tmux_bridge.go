// Package models defines the core data structures for tmuxinator projects.
package models

import (
	"github.com/tmuxinator/tmuxinator/internal/tmux"
)

// TmuxVersion returns the current tmux version as a float64.
// This bridges the tmux package into models without an import cycle.
func TmuxVersion() float64 {
	return tmux.GetVersion()
}

