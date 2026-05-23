// Package config handles tmuxinator configuration file discovery and loading.
package config

import (
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"github.com/tmuxinator/tmuxinator/internal/util"
)

const (
	// NoLocalFileMsg is shown when no local project file is found.
	NoLocalFileMsg = "Project file at ./.tmuxinator.yml doesn't exist."
	// NoProjectFoundMsg is shown when a project cannot be located.
	NoProjectFoundMsg = "Project could not be found."
)

// LocalDefaults lists the local project file names to search for.
var LocalDefaults = []string{"./.tmuxinator.yml", "./.tmuxinator.yaml"}

// Directory returns the primary config directory (creating it if needed).
// Search order:
//  1. $TMUXINATOR_CONFIG
//  2. $XDG_CONFIG_HOME/tmuxinator  (default: ~/.config/tmuxinator)
//  3. ~/.tmuxinator
func Directory() string {
	if env := environmentDir(); env != "" {
		return env
	}
	if xdg := xdgDir(); util.DirExists(xdg) {
		return xdg
	}
	if home := homeDir(); util.DirExists(home) {
		return home
	}
	// Default to XDG, creating it
	xdg := xdgDir()
	_ = util.EnsureDir(xdg)
	return xdg
}

// HomeDir returns ~/.tmuxinator.
func HomeDir() string {
	return homeDir()
}

func homeDir() string {
	return filepath.Join(util.HomeDir(), ".tmuxinator")
}

// XDGDir returns the XDG tmuxinator config directory.
func XDGDir() string {
	return xdgDir()
}

func xdgDir() string {
	return filepath.Join(util.XDGConfigHome(), "tmuxinator")
}

// EnvironmentDir returns $TMUXINATOR_CONFIG if set and valid.
func EnvironmentDir() string {
	return environmentDir()
}

func environmentDir() string {
	env := os.Getenv("TMUXINATOR_CONFIG")
	if env == "" {
		return ""
	}
	_ = util.EnsureDir(env)
	return env
}

// Directories returns all existent config directories in search order.
func Directories() []string {
	if env := environmentDir(); env != "" {
		return []string{env}
	}
	var dirs []string
	if xdg := xdgDir(); util.DirExists(xdg) {
		dirs = append(dirs, xdg)
	}
	if home := homeDir(); util.DirExists(home) {
		dirs = append(dirs, home)
	}
	return dirs
}

// DefaultProject returns the default path for a new project named name.
func DefaultProject(name string) string {
	return filepath.Join(Directory(), name+".yml")
}

// GlobalProject searches all global directories for a project named name.
// Returns the first match, or empty string if not found.
func GlobalProject(name string) string {
	dirs := []string{environmentDir(), xdgDir(), homeDir()}
	for _, dir := range dirs {
		if dir == "" {
			continue
		}
		if p := projectIn(dir, name); p != "" {
			return p
		}
	}
	return ""
}

// LocalProject returns the path to the local project file, or empty string.
func LocalProject() string {
	for _, f := range LocalDefaults {
		if util.FileExists(f) {
			return f
		}
	}
	return ""
}

// IsLocal returns true if a local project file exists.
func IsLocal() bool {
	return LocalProject() != ""
}

// Project returns the path to the project named name.
// Searches global directories first, then local, then returns the default path.
func Project(name string) string {
	if p := GlobalProject(name); p != "" {
		return p
	}
	if p := LocalProject(); p != "" {
		return p
	}
	return DefaultProject(name)
}

// Exist returns true if the project file exists.
// Provide either name or path (path takes precedence).
func Exist(name, path string) bool {
	if path != "" {
		return util.FileExists(path)
	}
	if name != "" {
		return util.FileExists(Project(name))
	}
	return false
}

// SamplePath returns the path to the bundled sample.yml.
func SamplePath() string {
	// Resolve relative to the executable or a well-known location.
	// In production this would be embedded; here we use a relative path.
	return assetPath("sample.yml")
}

// DefaultOrSample returns the path to default.yml if it exists, else sample.yml.
func DefaultOrSample() string {
	defaultPath := filepath.Join(Directory(), "default.yml")
	if util.FileExists(defaultPath) {
		return defaultPath
	}
	return SamplePath()
}

// Configs returns a sorted list of project names.
// If active is "true" only active sessions are returned;
// if "false" only inactive; otherwise all.
func Configs(active string, activeSessions []string) []string {
	names := configFileBasenames()
	switch active {
	case "true":
		names = intersect(names, activeSessions)
	case "false":
		names = subtract(names, activeSessions)
	}
	return names
}

// configFileBasenames returns sorted project names from all config directories.
func configFileBasenames() []string {
	var names []string
	for _, dir := range Directories() {
		files, err := util.GlobYAML(dir)
		if err != nil {
			continue
		}
		for _, f := range files {
			rel, err := filepath.Rel(dir, f)
			if err != nil {
				continue
			}
			// Strip .yml / .yaml extension
			name := strings.TrimSuffix(strings.TrimSuffix(rel, ".yml"), ".yaml")
			names = append(names, name)
		}
	}
	sort.Strings(names)
	return names
}

// projectIn searches dir recursively for a project named name.
func projectIn(dir, name string) string {
	if dir == "" {
		return ""
	}
	files, err := util.GlobYAML(dir)
	if err != nil {
		return ""
	}
	sort.Strings(files)
	for _, f := range files {
		base := strings.TrimSuffix(strings.TrimSuffix(filepath.Base(f), ".yml"), ".yaml")
		if base == name {
			return f
		}
	}
	return ""
}

// assetPath returns the path to a bundled asset file.
func assetPath(name string) string {
	// Try relative to the binary location, then relative to working directory.
	candidates := []string{
		filepath.Join("assets", name),
		filepath.Join("..", "assets", name),
		filepath.Join("..", "..", "assets", name),
	}
	for _, c := range candidates {
		if util.FileExists(c) {
			return c
		}
	}
	return filepath.Join("assets", name)
}

// intersect returns elements present in both a and b.
func intersect(a, b []string) []string {
	set := make(map[string]bool, len(b))
	for _, v := range b {
		set[v] = true
	}
	var result []string
	for _, v := range a {
		if set[v] {
			result = append(result, v)
		}
	}
	return result
}

// subtract returns elements in a that are not in b.
func subtract(a, b []string) []string {
	set := make(map[string]bool, len(b))
	for _, v := range b {
		set[v] = true
	}
	var result []string
	for _, v := range a {
		if !set[v] {
			result = append(result, v)
		}
	}
	return result
}

// ValidateOptions holds the parameters for Config.Validate.
type ValidateOptions struct {
	Name          string
	ProjectConfig string
	CustomName    string
	ForceAttach   bool
	ForceDetach   bool
	Append        bool
	NoPreWindow   bool
	Args          []string
}

// ValidateResult holds the resolved project file path and load options.
type ValidateResult struct {
	ProjectFile string
	Options     map[string]interface{}
}

// Validate resolves the project file and returns load options.
// It mirrors the Ruby Config.validate method.
func Validate(opts ValidateOptions) (*ValidateResult, error) {
	var projectFile string

	switch {
	case opts.ProjectConfig != "":
		if !util.FileExists(opts.ProjectConfig) {
			return nil, fmt.Errorf("project config (%s) doesn't exist", opts.ProjectConfig)
		}
		projectFile = opts.ProjectConfig

	case opts.Name == "":
		lp := LocalProject()
		if lp == "" {
			return nil, fmt.Errorf("%s", NoLocalFileMsg)
		}
		projectFile = lp

	default:
		if !Exist(opts.Name, "") {
			return nil, fmt.Errorf("project %s doesn't exist", opts.Name)
		}
		projectFile = Project(opts.Name)
	}

	return &ValidateResult{
		ProjectFile: projectFile,
		Options: map[string]interface{}{
			"custom_name":   opts.CustomName,
			"force_attach":  opts.ForceAttach,
			"force_detach":  opts.ForceDetach,
			"append":        opts.Append,
			"no_pre_window": opts.NoPreWindow,
			"args":          opts.Args,
		},
	}, nil
}

