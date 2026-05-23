// Package models defines the core data structures for tmuxinator projects.
package models

// Hooks holds the lifecycle hook commands for a project.
// Each field may be a single command string or multiple commands joined by "; ".
type Hooks struct {
	OnProjectStart      string
	OnProjectFirstStart string
	OnProjectRestart    string
	OnProjectExit       string
	OnProjectStop       string
}

// ParseHookField converts a hook YAML value (string or []interface{}) to a
// single shell command string.  Multiple commands are joined with "; ".
func ParseHookField(v interface{}) string {
	if v == nil {
		return ""
	}
	switch val := v.(type) {
	case string:
		return val
	case []interface{}:
		parts := make([]string, 0, len(val))
		for _, item := range val {
			if s, ok := item.(string); ok && s != "" {
				parts = append(parts, s)
			}
		}
		return joinCommands(parts)
	}
	return ""
}

func joinCommands(cmds []string) string {
	result := ""
	for i, c := range cmds {
		if i > 0 {
			result += "; "
		}
		result += c
	}
	return result
}

