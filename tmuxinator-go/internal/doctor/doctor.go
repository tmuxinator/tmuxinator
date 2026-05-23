// Package doctor provides environment validation for tmuxinator.
package doctor

import (
	"os"
	"os/exec"
)

// Installed returns true if tmux is available in PATH.
func Installed() bool {
	_, err := exec.LookPath("tmux")
	return err == nil
}

// EditorSet returns true if $EDITOR is set and non-empty.
func EditorSet() bool {
	e := os.Getenv("EDITOR")
	return e != ""
}

// ShellSet returns true if $SHELL is set and non-empty.
func ShellSet() bool {
	s := os.Getenv("SHELL")
	return s != ""
}

