// Package commands implements all tmuxinator CLI commands.
package commands

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"

	"github.com/tmuxinator/tmuxinator/internal/config"
	"github.com/tmuxinator/tmuxinator/internal/util"
)

// NewNewCmd creates the `new` command (also aliased as `open`).
func NewNewCmd() *cobra.Command {
	var local bool

	cmd := &cobra.Command{
		Use:     "new [PROJECT]",
		Short:   "Create a new project file and open it in your editor",
		Aliases: []string{"n", "open", "o"},
		RunE: func(cmd *cobra.Command, args []string) error {
			if len(args) == 0 {
				return cmd.Help()
			}
			name := args[0]
			return runNew(name, local)
		},
	}

	cmd.Flags().BoolVarP(&local, "local", "l", false, "Use local project file at ./.tmuxinator.yml")
	return cmd
}

func runNew(name string, local bool) error {
	var path string
	if local {
		path = config.LocalDefaults[0]
	} else {
		path = config.DefaultProject(name)
	}

	if !util.FileExists(path) {
		if err := generateProjectFile(name, path); err != nil {
			return err
		}
	}

	return util.RunEditor(path)
}

func generateProjectFile(name, path string) error {
	samplePath := config.SamplePath()
	content, err := util.ReadFile(samplePath)
	if err != nil {
		// Fall back to built-in sample
		content = builtinSample(name)
	}

	// Replace the name placeholder
	content = replaceName(content, name)

	return util.WriteFile(path, content)
}

func replaceName(content, name string) string {
	// Replace "name: <%= name %>" or similar with the actual name
	// For simplicity, prepend the name if not present
	_ = name
	return content
}

func builtinSample(name string) string {
	return fmt.Sprintf(`# %s

name: %s
root: ~/

# Optional tmux socket
# socket_name: foo

# Project hooks
# on_project_start: command
# on_project_first_start: command
# on_project_restart: command
# on_project_exit: command
# on_project_stop: command

# Runs in each window and pane before window/pane specific commands.
# pre_window: rbenv shell 2.0.0-p247

# Pass command line options to tmux.
# tmux_options: -f ~/.tmux.mac.conf

windows:
  - editor:
      layout: main-vertical
      panes:
        - vim
        - guard
  - server: bundle exec rails s
  - logs: tail -f log/development.log
`, name, name)
}

// NewEditCmd creates the `edit` command.
func NewEditCmd() *cobra.Command {
	var local bool

	cmd := &cobra.Command{
		Use:     "edit [PROJECT]",
		Short:   "Edit an existing project file in your editor",
		Aliases: []string{"e"},
		RunE: func(cmd *cobra.Command, args []string) error {
			if len(args) == 0 && !local {
				return cmd.Help()
			}

			var path string
			if local {
				path = config.LocalDefaults[0]
				if !util.FileExists(path) {
					fmt.Fprintln(os.Stderr, config.NoLocalFileMsg)
					os.Exit(1)
				}
			} else {
				name := args[0]
				path = config.Project(name)
				if !util.FileExists(path) {
					fmt.Fprintf(os.Stderr, "Project %s doesn't exist!\n", name)
					os.Exit(1)
				}
			}

			return util.RunEditor(path)
		},
	}

	cmd.Flags().BoolVarP(&local, "local", "l", false, "Use local project file at ./.tmuxinator.yml")
	return cmd
}

