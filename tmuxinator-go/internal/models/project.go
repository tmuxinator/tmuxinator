// Package models defines the core data structures for tmuxinator projects.
package models

import (
	"fmt"
	"os/exec"
	"strings"

	"github.com/tmuxinator/tmuxinator/internal/util"
)

// Project represents a fully-parsed tmuxinator project configuration.
type Project struct {
	// Raw YAML data
	yaml map[string]interface{}

	// Options set at load time
	CustomName  string
	ForceAttach bool
	ForceDetach bool
	Append      bool
	NoPreWindow bool

	// Cached parsed values
	windows    []*Window
	tmuxConfig map[string]string
}

// Deprecation messages (matching Ruby version)
const (
	RbenvRvmDepMsg = "DEPRECATION: rbenv/rvm-specific options have been replaced by the\n" +
		"    `pre_tab` option and will not be supported in 0.8.0."
	TabsDepMsg = "DEPRECATION: The tabs option has been replaced by the `windows` option\n" +
		"    and will not be supported in 0.8.0."
	CliArgsDepMsg = "DEPRECATION: The `cli_args` option has been replaced by the `tmux_options`\n" +
		"    option and will not be supported in 0.8.0."
	SyncDepMsg = "DEPRECATION: The `synchronize` option's current default behaviour is to\n" +
		"    enable pane synchronization before running commands. In a future release,\n" +
		"    the default synchronization option will be `after`, i.e. synchronization of\n" +
		"    panes will occur after the commands described in each of the panes\n" +
		"    have run. At that time, the current behavior will need to be explicitly\n" +
		"    enabled, using the `synchronize: before` option. To use this behaviour\n" +
		"    now, use the 'synchronize: after' option."
	PreDepMsg  = "DEPRECATION: The `pre` option has been replaced by project hooks (`on_project_start` and\n    `on_project_restart`) and will be removed in a future release."
	PostDepMsg = "DEPRECATION: The `post` option has been replaced by project hooks (`on_project_stop` and\n    `on_project_exit`) and will be removed in a future release."
)

// NewProject creates a Project from a parsed YAML map and load options.
func NewProject(yaml map[string]interface{}, opts map[string]interface{}) *Project {
	p := &Project{yaml: yaml}
	if v, ok := opts["custom_name"].(string); ok {
		p.CustomName = v
	}
	if v, ok := opts["force_attach"].(bool); ok {
		p.ForceAttach = v
	}
	if v, ok := opts["force_detach"].(bool); ok {
		p.ForceDetach = v
	}
	if v, ok := opts["append"].(bool); ok {
		p.Append = v
	}
	if v, ok := opts["no_pre_window"].(bool); ok {
		p.NoPreWindow = v
	}
	return p
}

// Validate checks that the project has required fields.
func (p *Project) Validate() error {
	if len(p.Windows()) == 0 {
		return fmt.Errorf("your project file should include some windows")
	}
	if p.Name() == "" {
		return fmt.Errorf("your project file didn't specify a 'project_name'")
	}
	if p.ForceAttach && p.ForceDetach {
		return fmt.Errorf("cannot force_attach and force_detach at the same time")
	}
	if p.Append && !p.TmuxHasSession(p.Name()) {
		return fmt.Errorf("cannot append to a session that does not exist")
	}
	return nil
}

// ---- Accessors ----

// Name returns the session name (shell-escaped, . and : replaced with __).
func (p *Project) Name() string {
	var name string
	if p.Append {
		name = util.CurrentSessionName()
	} else {
		name = p.CustomName
		if name == "" {
			name = p.yamlString("project_name")
		}
		if name == "" {
			name = p.yamlString("name")
		}
	}
	if name == "" {
		return ""
	}
	// Replace . and : with __
	name = strings.ReplaceAll(name, ".", "__")
	name = strings.ReplaceAll(name, ":", "__")
	return util.ShellEscape(name)
}

// Root returns the project root path (shell-escaped), or empty string.
func (p *Project) Root() string {
	root := p.yamlString("project_root")
	if root == "" {
		root = p.yamlString("root")
	}
	if root == "" {
		return ""
	}
	return util.ShellEscape(util.AbsPath(root))
}

// HasRoot returns true if a project root is defined.
func (p *Project) HasRoot() bool {
	return p.Root() != ""
}

// Pre returns the pre command(s) as a single string.
func (p *Project) Pre() string {
	return ParseHookField(p.yaml["pre"])
}

// Post returns the post command(s) as a single string.
func (p *Project) Post() string {
	return ParseHookField(p.yaml["post"])
}

// PreWindow returns the pre_window command, or empty string if NoPreWindow.
func (p *Project) PreWindow() string {
	if p.NoPreWindow {
		return ""
	}
	if rbenv := p.yamlString("rbenv"); rbenv != "" {
		return "rbenv shell " + rbenv
	}
	if rvm := p.yamlString("rvm"); rvm != "" {
		return "rvm use " + rvm
	}
	if preTab := p.yamlString("pre_tab"); preTab != "" {
		return preTab
	}
	return ParseHookField(p.yaml["pre_window"])
}

// Attach returns true if the session should be attached after creation.
func (p *Project) Attach() bool {
	if p.ForceAttach {
		return true
	}
	if p.ForceDetach {
		return false
	}
	v, ok := p.yaml["attach"]
	if !ok {
		return true // default: attach
	}
	if b, ok := v.(bool); ok {
		return b
	}
	return true
}

// TmuxCommand returns the tmux command (default: "tmux").
func (p *Project) TmuxCommand() string {
	if cmd := p.yamlString("tmux_command"); cmd != "" {
		return cmd
	}
	return "tmux"
}

// TmuxOptions returns extra tmux CLI options.
func (p *Project) TmuxOptions() string {
	if args := p.yamlString("cli_args"); args != "" {
		return " " + strings.TrimSpace(args)
	}
	if opts := p.yamlString("tmux_options"); opts != "" {
		return " " + strings.TrimSpace(opts)
	}
	return ""
}

// Socket returns the socket flag string (e.g. " -S /path" or " -L name").
func (p *Project) Socket() string {
	if path := p.yamlString("socket_path"); path != "" {
		return " -S " + path
	}
	if name := p.yamlString("socket_name"); name != "" {
		return " -L " + name
	}
	return ""
}

// Tmux returns the full tmux invocation string.
func (p *Project) Tmux() string {
	return p.TmuxCommand() + p.TmuxOptions() + p.Socket()
}

// DefaultPathOption returns the correct tmux option for setting the default path.
// For tmux < 1.8 it is "default-path"; for >= 1.8 it is "-c".
func (p *Project) DefaultPathOption() string {
	v := TmuxVersion()
	if v > 0 && v < 1.8 {
		return "default-path"
	}
	return "-c"
}

// BaseIndex returns the tmux base-index for windows.
// In append mode it returns last_window_index + 1.
func (p *Project) BaseIndex() int {
	if p.Append {
		return p.lastWindowIndex() + 1
	}
	if v, ok := p.tmuxConfigValue("base-index"); ok {
		if n, ok := parseIntSafe(v); ok {
			return n
		}
	}
	return 0
}

// PaneBaseIndex returns the tmux pane-base-index.
func (p *Project) PaneBaseIndex() int {
	if v, ok := p.tmuxConfigValue("pane-base-index"); ok {
		if n, ok := parseIntSafe(v); ok {
			return n
		}
	}
	return 0
}

// StartupWindow returns the tmux target for the startup window.
func (p *Project) StartupWindow() string {
	sw := p.yamlString("startup_window")
	if sw == "" {
		return p.Name() + ":" + itoa(p.BaseIndex())
	}
	return p.Name() + ":" + sw
}

// StartupPane returns the tmux target for the startup pane.
func (p *Project) StartupPane() string {
	sp := p.yamlString("startup_pane")
	if sp == "" {
		return p.StartupWindow() + "." + itoa(p.PaneBaseIndex())
	}
	return p.StartupWindow() + "." + sp
}

// TmuxStartupPaneCommand returns the select-pane command for the startup pane.
func (p *Project) TmuxStartupPaneCommand() string {
	return p.Tmux() + " select-pane -t " + p.StartupPane()
}

// WindowTarget returns the tmux window target for a given index.
func (p *Project) WindowTarget(index int) string {
	if p.Append {
		return ":" + itoa(index)
	}
	return p.Name() + ":" + itoa(index)
}

// SendKeys returns the send-keys command for a window.
func (p *Project) SendKeys(cmd string, windowIndex int) string {
	if cmd == "" {
		return ""
	}
	return p.Tmux() + " send-keys -t " + p.WindowTarget(windowIndex) + " " + util.ShellEscape(cmd) + " C-m"
}

// TmuxNewSessionCommand returns the new-session command, or empty in append mode.
func (p *Project) TmuxNewSessionCommand() string {
	if p.Append {
		return ""
	}
	nameOpt := ""
	if p.Name() != "" {
		nameOpt = "-s " + p.Name() + " "
	}
	windowNameOpt := ""
	if len(p.Windows()) > 0 {
		windowNameOpt = p.Windows()[0].TmuxWindowNameOption()
	}
	return p.Tmux() + " new-session -d " + nameOpt + windowNameOpt
}

// TmuxKillSessionCommand returns the kill-session command.
func (p *Project) TmuxKillSessionCommand() string {
	return p.Tmux() + " kill-session -t " + p.Name()
}

// ShowTmuxOptions returns the command to show tmux global options.
func (p *Project) ShowTmuxOptions() string {
	return p.Tmux() + ` start-server\; show-option -g base-index\; show-window-option -g pane-base-index\;`
}

// TmuxHasSession returns true if a tmux session with the given name exists.
func (p *Project) TmuxHasSession(name string) bool {
	if name == "" {
		return false
	}
	out, err := exec.Command("sh", "-c", p.Tmux()+" ls 2>/dev/null").Output()
	if err != nil {
		return false
	}
	// Unescape name (remove shell escaping)
	unescaped := strings.Trim(name, "'")
	lines := strings.Split(string(out), "\n")
	for _, line := range lines {
		if strings.HasPrefix(line, unescaped+":") {
			return true
		}
	}
	return false
}

// EnablePaneTitles returns true if pane titles are enabled.
func (p *Project) EnablePaneTitles() bool {
	v, ok := p.yaml["enable_pane_titles"]
	if !ok {
		return false
	}
	b, ok := v.(bool)
	return ok && b
}

// PaneTitlePosition returns the configured pane title position.
func (p *Project) PaneTitlePosition() string {
	return p.yamlString("pane_title_position")
}

// PaneTitlePositionValid returns true if the position is top, bottom, or off.
func (p *Project) PaneTitlePositionValid() bool {
	pos := p.PaneTitlePosition()
	return pos == "top" || pos == "bottom" || pos == "off"
}

// PaneTitleFormat returns the configured pane title format.
func (p *Project) PaneTitleFormat() string {
	return p.yamlString("pane_title_format")
}

// TmuxSetPaneTitlePosition returns the set-window-option pane-border-status command.
func (p *Project) TmuxSetPaneTitlePosition(windowTarget string) string {
	cmd := p.Tmux() + " set-window-option -t " + windowTarget
	pos := p.PaneTitlePosition()
	if pos != "" && p.PaneTitlePositionValid() {
		return cmd + " pane-border-status " + pos
	}
	return cmd + " pane-border-status top"
}

// TmuxSetPaneTitleFormat returns the set-window-option pane-border-format command.
func (p *Project) TmuxSetPaneTitleFormat(windowTarget string) string {
	cmd := p.Tmux() + " set-window-option -t " + windowTarget
	if f := p.PaneTitleFormat(); f != "" {
		return cmd + ` pane-border-format "` + f + `"`
	}
	return cmd + ` pane-border-format "#{pane_index}: #{pane_title}"`
}

// PaneTitlePositionNotValidWarning returns a printf warning command.
func (p *Project) PaneTitlePositionNotValidWarning() string {
	return p.printWarning(
		"The specified pane title position '" + p.PaneTitlePosition() +
			"' is not valid. Please choose one of: top, bottom, or off.",
	)
}

// PaneTitlesNotSupportedWarning returns a printf warning command.
func (p *Project) PaneTitlesNotSupportedWarning() string {
	return p.printWarning(
		"You have enabled pane titles in your configuration, but the " +
			"feature is not supported by your version of tmux.\nPlease consider " +
			"upgrading to a version that supports it (tmux >=2.6).",
	)
}

func (p *Project) printWarning(msg string) string {
	yellow := `\033[1;33m`
	noColor := `\033[0m`
	return `printf "` + yellow + `WARNING: ` + msg + `\n` + noColor + `"`
}

// Hooks returns the project lifecycle hooks.
func (p *Project) Hooks() *Hooks {
	return &Hooks{
		OnProjectStart:      ParseHookField(p.yaml["on_project_start"]),
		OnProjectFirstStart: ParseHookField(p.yaml["on_project_first_start"]),
		OnProjectRestart:    ParseHookField(p.yaml["on_project_restart"]),
		OnProjectExit:       ParseHookField(p.yaml["on_project_exit"]),
		OnProjectStop:       ParseHookField(p.yaml["on_project_stop"]),
	}
}

// Deprecations returns a list of deprecation warning messages for this project.
func (p *Project) Deprecations() []string {
	var deps []string
	if p.yamlString("rvm") != "" || p.yamlString("rbenv") != "" {
		deps = append(deps, RbenvRvmDepMsg)
	}
	if p.yaml["tabs"] != nil {
		deps = append(deps, TabsDepMsg)
	}
	if p.yamlString("cli_args") != "" {
		deps = append(deps, CliArgsDepMsg)
	}
	if p.hasLegacySynchronize() {
		deps = append(deps, SyncDepMsg)
	}
	if p.yaml["pre"] != nil {
		deps = append(deps, PreDepMsg)
	}
	if p.yaml["post"] != nil {
		deps = append(deps, PostDepMsg)
	}
	return deps
}

// Windows returns the parsed list of windows for this project.
func (p *Project) Windows() []*Window {
	if p.windows != nil {
		return p.windows
	}

	var windowsYAML []interface{}
	if tabs, ok := p.yaml["tabs"].([]interface{}); ok {
		windowsYAML = tabs
	} else if wins, ok := p.yaml["windows"].([]interface{}); ok {
		windowsYAML = wins
	}

	p.windows = make([]*Window, 0, len(windowsYAML))
	for i, wy := range windowsYAML {
		w := p.parseWindow(wy, i)
		if w != nil {
			p.windows = append(p.windows, w)
		}
	}
	return p.windows
}

// parseWindow converts a raw YAML window entry into a Window model.
func (p *Project) parseWindow(raw interface{}, index int) *Window {
	wm, ok := raw.(map[string]interface{})
	if !ok {
		return nil
	}

	// Each window entry is a map with one key (the window name)
	var windowName string
	var windowValue interface{}
	for k, v := range wm {
		windowName = k
		windowValue = v
		break
	}

	w := &Window{
		Index:   index,
		Project: p,
	}

	if windowName != "" {
		w.RawName = windowName
		w.Name = util.ShellEscape(windowName)
	}

	// windowValue can be nil, a string (single command), or a map
	switch val := windowValue.(type) {
	case nil:
		// No commands, no panes
	case string:
		// Single command
		if val != "" {
			w.Commands = []string{
				p.Tmux() + " send-keys -t " + p.Name() + ":" + itoa(index+p.BaseIndex()) + " " + util.ShellEscape(val) + " C-m",
			}
		}
	case []interface{}:
		// List of commands (window-level, no panes)
		for _, item := range val {
			if s, ok := item.(string); ok && s != "" {
				w.Commands = append(w.Commands,
					p.Tmux()+" send-keys -t "+p.Name()+":"+itoa(index+p.BaseIndex())+" "+util.ShellEscape(s)+" C-m",
				)
			}
		}
	case map[string]interface{}:
		// Full window config
		if layout, ok := val["layout"].(string); ok {
			w.Layout = util.ShellEscape(layout)
		}
		if root, ok := val["root"].(string); ok {
			w.windowRoot = root
		}
		if focusedPane, ok := val["focused_pane"]; ok {
			switch fp := focusedPane.(type) {
			case string:
				w.focusedPaneConfig = fp
			case int:
				w.focusedPaneConfig = itoa(fp)
			}
		}
		// Parse synchronize
		if sync, ok := val["synchronize"]; ok {
			switch sv := sync.(type) {
			case bool:
				if sv {
					w.Synchronize = "before"
				}
			case string:
				w.Synchronize = sv
			}
		}
		// Parse window-level pre
		if pre, ok := val["pre"]; ok {
			switch pv := pre.(type) {
			case string:
				w.pre = pv
			case []interface{}:
				parts := make([]string, 0)
				for _, item := range pv {
					if s, ok := item.(string); ok && s != "" {
						parts = append(parts, s)
					}
				}
				w.pre = strings.Join(parts, " && ")
			}
		}
		// Parse panes
		if panesRaw, ok := val["panes"].([]interface{}); ok {
			w.Panes = p.parsePanes(panesRaw, w)
		}
	}

	return w
}

// parsePanes converts raw YAML pane entries into Pane models.
func (p *Project) parsePanes(raw []interface{}, w *Window) []*Pane {
	panes := make([]*Pane, 0, len(raw))
	for i, paneRaw := range raw {
		pane := &Pane{
			Index:   i,
			Window:  w,
			Project: p,
		}
		switch pv := paneRaw.(type) {
		case nil:
			// empty pane
		case string:
			if pv != "" {
				pane.Commands = []string{pv}
			}
		case map[string]interface{}:
			// Pane with title and/or multiple commands
			for title, cmdsRaw := range pv {
				pane.Title = util.ShellEscape(title)
				switch cv := cmdsRaw.(type) {
				case string:
					if cv != "" {
						pane.Commands = []string{cv}
					}
				case []interface{}:
					for _, c := range cv {
						if s, ok := c.(string); ok && s != "" {
							pane.Commands = append(pane.Commands, s)
						}
					}
				}
				break // only one key per pane map
			}
		case []interface{}:
			for _, c := range pv {
				if s, ok := c.(string); ok && s != "" {
					pane.Commands = append(pane.Commands, s)
				}
			}
		}
		panes = append(panes, pane)
	}
	return panes
}

// ---- Private helpers ----

func (p *Project) yamlString(key string) string {
	v, ok := p.yaml[key]
	if !ok {
		return ""
	}
	switch s := v.(type) {
	case string:
		return s
	case int:
		return itoa(s)
	case float64:
		return fmt.Sprintf("%g", s)
	}
	return ""
}

func (p *Project) tmuxConfigValue(key string) (string, bool) {
	cfg := p.getTmuxConfig()
	v, ok := cfg[key]
	return v, ok
}

func (p *Project) getTmuxConfig() map[string]string {
	if p.tmuxConfig != nil {
		return p.tmuxConfig
	}
	p.tmuxConfig = map[string]string{}
	out, err := exec.Command("sh", "-c", p.ShowTmuxOptions()).Output()
	if err != nil {
		return p.tmuxConfig
	}
	for _, line := range strings.Split(string(out), "\n") {
		parts := strings.Fields(line)
		if len(parts) >= 2 {
			p.tmuxConfig[parts[0]] = parts[1]
		}
	}
	return p.tmuxConfig
}

func (p *Project) lastWindowIndex() int {
	out, err := exec.Command("tmux", "list-windows", "-F", "#I").Output()
	if err != nil {
		return 0
	}
	lines := strings.Split(strings.TrimSpace(string(out)), "\n")
	if len(lines) == 0 {
		return 0
	}
	last := lines[len(lines)-1]
	if n, ok := parseIntSafe(strings.TrimSpace(last)); ok {
		return n
	}
	return 0
}

func (p *Project) hasLegacySynchronize() bool {
	wins, ok := p.yaml["windows"].([]interface{})
	if !ok {
		return false
	}
	for _, w := range wins {
		wm, ok := w.(map[string]interface{})
		if !ok {
			continue
		}
		for _, v := range wm {
			vm, ok := v.(map[string]interface{})
			if !ok {
				continue
			}
			if sync, ok := vm["synchronize"]; ok {
				switch sv := sync.(type) {
				case bool:
					if sv {
						return true
					}
				case string:
					if sv == "before" {
						return true
					}
				}
			}
		}
	}
	return false
}

