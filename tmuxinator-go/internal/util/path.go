// Package util provides path-related utility functions for tmuxinator.
package util

import (
	"os"
	"path/filepath"
	"strings"
)

// ExpandHome expands a leading ~ in a path to the user's home directory.
func ExpandHome(path string) string {
	if path == "" {
		return path
	}
	if path == "~" {
		return HomeDir()
	}
	if strings.HasPrefix(path, "~/") {
		return filepath.Join(HomeDir(), path[2:])
	}
	return path
}

// HomeDir returns the current user's home directory.
func HomeDir() string {
	if home := os.Getenv("HOME"); home != "" {
		return home
	}
	// Fallback for Windows
	if home := os.Getenv("USERPROFILE"); home != "" {
		return home
	}
	return "."
}

// XDGConfigHome returns the XDG config home directory, defaulting to ~/.config.
func XDGConfigHome() string {
	if xdg := os.Getenv("XDG_CONFIG_HOME"); xdg != "" {
		return xdg
	}
	return filepath.Join(HomeDir(), ".config")
}

// AbsPath returns the absolute path, expanding ~ and resolving relative paths.
func AbsPath(path string) string {
	expanded := ExpandHome(path)
	abs, err := filepath.Abs(expanded)
	if err != nil {
		return expanded
	}
	return abs
}

// JoinPath joins path elements, expanding ~ in the first element.
func JoinPath(elem ...string) string {
	if len(elem) == 0 {
		return ""
	}
	elem[0] = ExpandHome(elem[0])
	return filepath.Join(elem...)
}

