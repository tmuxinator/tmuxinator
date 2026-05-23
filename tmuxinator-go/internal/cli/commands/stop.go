// Package commands implements all tmuxinator CLI commands.
package commands

import (
	"github.com/spf13/cobra"

	"github.com/tmuxinator/tmuxinator/internal/config"
	"github.com/tmuxinator/tmuxinator/internal/template"
	"github.com/tmuxinator/tmuxinator/internal/tmux"
)

// NewStopCmd creates the `stop` command.
func NewStopCmd() *cobra.Command {
	var (
		projectConfig   string
		suppressWarning bool
	)

	cmd := &cobra.Command{
		Use:     "stop [PROJECT]",
		Short:   "Stop a tmux session using a project's tmuxinator config",
		Aliases: []string{"st"},
		RunE: func(cmd *cobra.Command, args []string) error {
			return runStop(args, projectConfig, suppressWarning)
		},
	}

	cmd.Flags().StringVarP(&projectConfig, "project-config", "p", "", "Path to project config file")
	cmd.Flags().BoolVar(&suppressWarning, "suppress-tmux-version-warning", false, "Don't show a warning for unsupported tmux versions")

	return cmd
}

func runStop(args []string, projectConfig string, suppressWarning bool) error {
	name := ""
	if projectConfig == "" && len(args) > 0 {
		name = args[0]
	}

	if !suppressWarning && !tmux.IsSupported() {
		printVersionWarning()
	}

	project, err := config.ValidateProject(config.ValidateOptions{
		Name:          name,
		ProjectConfig: projectConfig,
	})
	if err != nil {
		return err
	}

	script, err := template.RenderStop(project)
	if err != nil {
		return err
	}

	return execScript(script)
}

