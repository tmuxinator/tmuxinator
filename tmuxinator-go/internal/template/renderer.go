// Package template renders tmuxinator shell scripts from project models.
package template

import (
	"bytes"
	"fmt"
	"strings"

	"github.com/tmuxinator/tmuxinator/internal/models"
	"github.com/tmuxinator/tmuxinator/internal/tmux"
	"github.com/tmuxinator/tmuxinator/internal/util"
)

// RenderStart generates the shell script that creates a tmux session.
func RenderStart(p *models.Project) (string, error) {
	return collapseBlankLines(buildStartScript(p)), nil
}

// RenderStop generates the shell script that stops a tmux session.
func RenderStop(p *models.Project) (string, error) {
	return collapseBlankLines(buildStopScript(p)), nil
}

// collapseBlankLines removes consecutive blank lines from a script.
func collapseBlankLines(script string) string {
	lines := strings.Split(script, "\n")
	var out []string
	prevBlank := false
	for _, line := range lines {
		isBlank := strings.TrimSpace(line) == ""
		if isBlank && prevBlank {
			continue
		}
		out = append(out, line)
		prevBlank = isBlank
	}
	return strings.Join(out, "\n")
}

// buildStartScript constructs the session-creation shell script imperatively.
// This mirrors the Ruby template.erb logic exactly.
func buildStartScript(p *models.Project) string {
	var b scriptBuilder
	tv := tmux.GetVersion()
	hooks := p.Hooks()

	b.shebang()
	b.blank()

	if !p.Append {
		b.comment("Clear rbenv variables before starting tmux")
		b.line("unset RBENV_VERSION")
		b.line("unset RBENV_DIR")
		b.blank()
		b.line(p.Tmux() + " start-server;")
	}

	b.blank()
	if p.HasRoot() {
		b.line("cd " + p.Root())
	} else {
		b.line("cd .")
	}
	b.blank()

	b.comment("Run on_project_start command.")
	if hooks.OnProjectStart != "" {
		b.line(hooks.OnProjectStart)
	}
	b.blank()

	hasSession := p.TmuxHasSession(p.Name())

	if p.Append || !hasSession {
		b.blank()
		b.comment("Run pre command.")
		if p.Pre() != "" {
			b.line(p.Pre())
		}
		b.blank()
		b.comment("Run on_project_first_start command.")
		if hooks.OnProjectFirstStart != "" {
			b.line(hooks.OnProjectFirstStart)
		}
		b.blank()
		if cmd := p.TmuxNewSessionCommand(); cmd != "" {
			b.line(cmd)
		}
		b.blank()

		if tv > 0 && tv < 1.7 {
			b.comment("Set the default path for versions prior to 1.7")
			if p.HasRoot() {
				b.line(p.Tmux() + " set-option -t " + p.Name() + " " +
					p.DefaultPathOption() + " " + p.Root() + " 1>/dev/null")
			}
		}

		if p.EnablePaneTitles() {
			if tv > 0 && tv < 2.6 {
				b.line(p.PaneTitlesNotSupportedWarning())
			}
			if p.PaneTitlePosition() != "" && !p.PaneTitlePositionValid() {
				b.line(p.PaneTitlePositionNotValidWarning())
			}
		}

		b.blank()
		b.comment("Create windows.")
		for _, w := range p.Windows() {
			b.line(w.TmuxNewWindowCommand())
		}
		b.blank()

		for _, w := range p.Windows() {
			b.blank()
			b.comment(fmt.Sprintf("Window %q", w.RawName))

			if w.SynchronizeBefore() {
				b.line(w.TmuxSynchronizePanes())
			}

			if p.EnablePaneTitles() && tv >= 2.6 {
				b.line(p.TmuxSetPaneTitlePosition(w.TmuxWindowTarget()))
				b.line(p.TmuxSetPaneTitleFormat(w.TmuxWindowTarget()))
			}

			if !w.HasPanes() {
				if p.PreWindow() != "" {
					b.line(w.TmuxPreWindowCommand())
				}
				for _, cmd := range w.Commands {
					b.line(cmd)
				}
			} else {
				for _, pane := range w.Panes {
					if tv >= 2.6 && pane.Title != "" {
						b.line(pane.TmuxSetTitle())
					}
					if p.PreWindow() != "" {
						b.line(pane.TmuxPreWindowCommand())
					}
					if w.Pre() != "" {
						b.line(pane.TmuxPreCommand())
					}
					for _, cmd := range pane.Commands {
						b.line(pane.TmuxMainCommand(cmd))
					}
					if !pane.IsLast() {
						b.line(pane.TmuxSplitCommand())
					}
					b.line(w.TmuxTiledLayoutCommand())
				}
				if w.Layout != "" {
					b.line(w.TmuxLayoutCommand())
				}
				b.line(w.TmuxFocusPaneCommand())
			}

			if w.SynchronizeAfter() {
				b.line(w.TmuxSynchronizePanes())
			}
		}

		b.blank()
		b.line(p.Tmux() + " select-window -t " + p.StartupWindow())
		b.line(p.TmuxStartupPaneCommand())
	} else {
		b.comment("Run on_project_restart command.")
		if hooks.OnProjectRestart != "" {
			b.line(hooks.OnProjectRestart)
		}
	}

	b.blank()
	if p.Attach() && !p.Append {
		b.line(`if [ -z "$TMUX" ]; then`)
		b.line("  " + p.Tmux() + " -u attach-session -t " + p.Name())
		b.line("else")
		b.line("  " + p.Tmux() + " -u switch-client -t " + p.Name())
		b.line("fi")
	}

	b.blank()
	if p.Post() != "" {
		b.line(p.Post())
	}
	b.blank()
	b.comment("Run on_project_exit command.")
	if hooks.OnProjectExit != "" {
		b.line(hooks.OnProjectExit)
	}

	return b.String()
}

// buildStopScript constructs the session-stop shell script.
func buildStopScript(p *models.Project) string {
	var b scriptBuilder
	hooks := p.Hooks()

	b.shebang()
	b.blank()

	if p.TmuxHasSession(p.Name()) {
		if p.HasRoot() {
			b.line("cd " + p.Root())
		} else {
			b.line("cd .")
		}
		b.blank()
		b.comment("Run on_project_stop command")
		if hooks.OnProjectStop != "" {
			b.line(hooks.OnProjectStop)
		}
		b.blank()
		b.line(p.TmuxKillSessionCommand())
	}

	return b.String()
}

// scriptBuilder is a simple string builder for shell scripts.
type scriptBuilder struct {
	buf bytes.Buffer
}

func (s *scriptBuilder) shebang() {
	s.buf.WriteString("#!" + util.Shell() + "\n")
}

func (s *scriptBuilder) blank() {
	s.buf.WriteString("\n")
}

func (s *scriptBuilder) comment(text string) {
	s.buf.WriteString("# " + text + "\n")
}

func (s *scriptBuilder) line(text string) {
	if text == "" {
		return
	}
	s.buf.WriteString(text + "\n")
}

func (s *scriptBuilder) String() string {
	return s.buf.String()
}

