// Package tmux provides tmux interaction utilities.
package tmux

import (
	"math"
	"os/exec"
	"strconv"
	"strings"
)

// SupportedVersions lists all tmux versions that tmuxinator supports.
var SupportedVersions = []string{
	"3.6b", "3.6a", "3.6",
	"3.5a", "3.5",
	"3.4",
	"3.3a", "3.3",
	"3.2a", "3.2",
	"3.1c", "3.1b", "3.1a", "3.1",
	"3.0a", "3.0",
	"2.9a", "2.9",
	"2.8",
	"2.7",
	"2.6",
	"2.5",
	"2.4",
	"2.3",
	"2.2",
	"2.1",
	"2.0",
	"1.9",
	"1.8",
	"1.7",
	"1.6",
	"1.5",
}

// UnsupportedVersionMsg is shown when an unsupported tmux version is detected.
var UnsupportedVersionMsg = "WARNING: You are running tmuxinator with an unsupported version of tmux.\n" +
	"Please consider using a supported version:\n" +
	"(" + strings.Join(SupportedVersions, ", ") + ")"

// Installed returns true if tmux is available in PATH.
func Installed() bool {
	_, err := exec.LookPath("tmux")
	return err == nil
}

// VersionString returns the raw version string from `tmux -V` (e.g. "3.4").
func VersionString() string {
	if !Installed() {
		return ""
	}
	out, err := exec.Command("tmux", "-V").Output()
	if err != nil {
		return ""
	}
	parts := strings.Fields(strings.TrimSpace(string(out)))
	if len(parts) < 2 {
		return ""
	}
	return parts[1]
}

// Version returns the numeric tmux version (e.g. 3.4).
// For "master" it returns +Inf. Returns 0 if tmux is not installed.
func Version() float64 {
	vs := VersionString()
	if vs == "" {
		return 0
	}
	if vs == "master" {
		return math.Inf(1)
	}
	// Strip trailing letters (e.g. "3.2a" -> "3.2")
	numeric := strings.TrimRight(vs, "abcdefghijklmnopqrstuvwxyz")
	f, err := strconv.ParseFloat(numeric, 64)
	if err != nil {
		return 0
	}
	return f
}

// IsSupported returns true if the current tmux version is in SupportedVersions.
func IsSupported() bool {
	vs := VersionString()
	if vs == "" {
		return false
	}
	for _, sv := range SupportedVersions {
		if sv == vs {
			return true
		}
	}
	return false
}

// tmuxVersion is a package-level cache so models can call it without import cycles.
var cachedVersion *float64

// GetVersion returns the cached tmux version float.
func GetVersion() float64 {
	if cachedVersion != nil {
		return *cachedVersion
	}
	v := Version()
	cachedVersion = &v
	return v
}

