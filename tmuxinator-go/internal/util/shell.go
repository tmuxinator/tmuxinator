// Package util provides shell-related utility functions for tmuxinator.
package util

import (
	"os"
	"os/exec"
	"strings"
)

// ShellEscape returns a shell-safe version of s.
// It wraps the string in single quotes and escapes any single quotes within.
func ShellEscape(s string) string {
	if s == "" {
		return "''"
	}
	// Replace ' with '\''
	escaped := strings.ReplaceAll(s, "'", `'\''`)
	return "'" + escaped + "'"
}

// Shell returns the user's preferred shell from $SHELL, defaulting to /bin/sh.
func Shell() string {
	if sh := os.Getenv("SHELL"); sh != "" {
		return sh
	}
	return "/bin/sh"
}

// Editor returns the user's preferred editor from $EDITOR.
func Editor() string {
	return os.Getenv("EDITOR")
}

// RunEditor opens the given file in the user's $EDITOR.
// Returns an error if $EDITOR is not set or the command fails.
func RunEditor(path string) error {
	editor := Editor()
	if editor == "" {
		return &ErrNoEditor{}
	}
	cmd := exec.Command(editor, path)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

// ErrNoEditor is returned when $EDITOR is not set.
type ErrNoEditor struct{}

func (e *ErrNoEditor) Error() string {
	return "$EDITOR is not set"
}

// CurrentSessionName returns the name of the current tmux session, if any.
func CurrentSessionName() string {
	if os.Getenv("TMUX") == "" {
		return ""
	}
	out, err := exec.Command("tmux", "display-message", "-p", "#S").Output()
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(out))
}

