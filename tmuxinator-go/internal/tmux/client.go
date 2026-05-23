// Package tmux provides tmux interaction utilities.
package tmux

import (
	"os/exec"
	"strings"
)

// ActiveSessions returns the list of currently active tmux session names.
func ActiveSessions() []string {
	out, err := exec.Command("tmux", "list-sessions", "-F", "#S").Output()
	if err != nil {
		return nil
	}
	lines := strings.Split(strings.TrimSpace(string(out)), "\n")
	result := make([]string, 0, len(lines))
	for _, l := range lines {
		if l != "" {
			result = append(result, l)
		}
	}
	return result
}

// HasSession returns true if a tmux session with the given name exists.
func HasSession(name string) bool {
	if name == "" {
		return false
	}
	out, err := exec.Command("sh", "-c", "tmux ls 2>/dev/null").Output()
	if err != nil {
		return false
	}
	for _, line := range strings.Split(string(out), "\n") {
		if strings.HasPrefix(line, name+":") {
			return true
		}
	}
	return false
}

