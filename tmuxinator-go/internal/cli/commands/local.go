// Package commands implements all tmuxinator CLI commands.
package commands

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"

	"github.com/tmuxinator/tmuxinator/internal/config"
	"github.com/tmuxinator/tmuxinator/internal/template"
	"github.com/tmuxinator/tmuxinator/internal/tmux"
)

// NewLocalCmd creates the `local` command.
func NewLocalCmd() *cobra.Command {
	var (
		attach          bool
		suppressWarning bool
	)

	cmd := &cobra.Command{
		Use:     "local",
		Short:   "Start a tmux session using ./.tmuxinator.y[a]ml",
		Aliases: []string{"."},
		RunE: func(cmd *cobra.Command, args []string) error {
			if !suppressWarning && !tmux.IsSupported() {
				printVersionWarning()
			}

			forceAttach, forceDetach := false, false
			if cmd.Flags().Changed("attach") {
				if attach {
					forceAttach = true
				} else {
					forceDetach = true
				}
			}

			project, err := config.ValidateProject(config.ValidateOptions{
				ForceAttach: forceAttach,
				ForceDetach: forceDetach,
			})
			if err != nil {
				return err
			}

			script, err := template.RenderStart(project)
			if err != nil {
				return err
			}

			return execScript(script)
		},
	}

	cmd.Flags().BoolVarP(&attach, "attach", "a", false, "Attach to tmux session after creation")
	cmd.Flags().BoolVar(&suppressWarning, "suppress-tmux-version-warning", false, "Don't show a warning for unsupported tmux versions")
	return cmd
}

// NewStopAllCmd creates the `stop-all` command.
func NewStopAllCmd() *cobra.Command {
	var noConfirm bool

	cmd := &cobra.Command{
		Use:   "stop-all",
		Short: "Stop all tmux sessions which are using tmuxinator projects",
		RunE: func(cmd *cobra.Command, args []string) error {
			sessions := tmux.ActiveSessions()
			configs := config.Configs("true", sessions)

			if !noConfirm {
				fmt.Println("Stop all active projects:\n")
				for _, c := range configs {
					fmt.Println(c)
				}
				fmt.Println()
				fmt.Print("Are you sure? (n/y): ")
				var answer string
				fmt.Scanln(&answer)
				if answer != "y" && answer != "Y" {
					return nil
				}
			}

			for _, name := range configs {
				project, err := config.ValidateProject(config.ValidateOptions{Name: name})
				if err != nil {
					fmt.Fprintf(os.Stderr, "Error loading %s: %v\n", name, err)
					continue
				}
				script, err := template.RenderStop(project)
				if err != nil {
					fmt.Fprintf(os.Stderr, "Error rendering stop for %s: %v\n", name, err)
					continue
				}
				if err := execScript(script); err != nil {
					fmt.Fprintf(os.Stderr, "Error stopping %s: %v\n", name, err)
				}
			}
			return nil
		},
	}

	cmd.Flags().BoolVarP(&noConfirm, "noconfirm", "y", false, "Skip confirmation prompt")
	return cmd
}

