// Package commands implements all tmuxinator CLI commands.
package commands

import (
	"fmt"
	"os"
	"os/exec"

	"github.com/spf13/cobra"

	"github.com/tmuxinator/tmuxinator/internal/config"
	"github.com/tmuxinator/tmuxinator/internal/template"
	"github.com/tmuxinator/tmuxinator/internal/tmux"
)

// NewStartCmd creates the `start` command.
func NewStartCmd() *cobra.Command {
	var (
		attach          bool
		noAttach        bool
		customName      string
		projectConfig   string
		suppressWarning bool
		appendMode      bool
		noPreWindow     bool
	)

	cmd := &cobra.Command{
		Use:     "start [PROJECT] [ARGS...]",
		Short:   "Start a tmux session using a project's name or a path to a project config file",
		Aliases: []string{"s"},
		RunE: func(cmd *cobra.Command, args []string) error {
			return runStart(args, startOptions{
				attach:          resolveAttach(cmd, attach, noAttach),
				customName:      customName,
				projectConfig:   projectConfig,
				suppressWarning: suppressWarning,
				appendMode:      appendMode,
				noPreWindow:     noPreWindow,
			})
		},
	}

	cmd.Flags().BoolVarP(&attach, "attach", "a", false, "Attach to tmux session after creation")
	cmd.Flags().BoolVar(&noAttach, "no-attach", false, "Do not attach to tmux session after creation")
	cmd.Flags().StringVarP(&customName, "name", "n", "", "Give the session a different name")
	cmd.Flags().StringVarP(&projectConfig, "project-config", "p", "", "Path to project config file")
	cmd.Flags().BoolVar(&suppressWarning, "suppress-tmux-version-warning", false, "Don't show a warning for unsupported tmux versions")
	cmd.Flags().BoolVar(&appendMode, "append", false, "Append the project windows and panes to the current session")
	cmd.Flags().BoolVar(&noPreWindow, "no-pre-window", false, "Skip pre_window commands")

	return cmd
}

type startOptions struct {
	attach          *bool
	customName      string
	projectConfig   string
	suppressWarning bool
	appendMode      bool
	noPreWindow     bool
}

func runStart(args []string, opts startOptions) error {
	name, projectArgs := extractNameAndArgs(args, opts.projectConfig)

	if !opts.suppressWarning && !tmux.IsSupported() {
		fmt.Fprintln(os.Stderr, tmux.UnsupportedVersionMsg)
		fmt.Fprint(os.Stderr, "\nPress ENTER to continue.")
		fmt.Scanln()
	}

	forceAttach, forceDetach := resolveAttachFlags(opts.attach)

	project, err := config.ValidateProject(config.ValidateOptions{
		Name:          name,
		ProjectConfig: opts.projectConfig,
		CustomName:    opts.customName,
		ForceAttach:   forceAttach,
		ForceDetach:   forceDetach,
		Append:        opts.appendMode,
		NoPreWindow:   opts.noPreWindow,
		Args:          projectArgs,
	})
	if err != nil {
		return err
	}

	if len(project.Deprecations()) > 0 {
		for _, dep := range project.Deprecations() {
			fmt.Fprintln(os.Stderr, dep)
		}
		fmt.Fprint(os.Stderr, "\nPress ENTER to continue.")
		fmt.Scanln()
	}

	script, err := template.RenderStart(project)
	if err != nil {
		return err
	}

	return execScript(script)
}

// extractNameAndArgs separates the project name from extra args.
// If projectConfig is set, all args are treated as project args.
func extractNameAndArgs(args []string, projectConfig string) (string, []string) {
	if projectConfig != "" {
		return "", args
	}
	if len(args) == 0 {
		return "", nil
	}
	return args[0], args[1:]
}

// resolveAttach converts cobra flag state to a *bool.
func resolveAttach(cmd *cobra.Command, attach, noAttach bool) *bool {
	if cmd.Flags().Changed("attach") {
		return &attach
	}
	if cmd.Flags().Changed("no-attach") {
		f := false
		return &f
	}
	return nil
}

// resolveAttachFlags converts a *bool to forceAttach/forceDetach booleans.
func resolveAttachFlags(attach *bool) (forceAttach, forceDetach bool) {
	if attach == nil {
		return false, false
	}
	if *attach {
		return true, false
	}
	return false, true
}

// execScript writes the script to a temp file and exec's it.
func execScript(script string) error {
	f, err := os.CreateTemp("", "tmuxinator-*.sh")
	if err != nil {
		return fmt.Errorf("failed to create temp script: %w", err)
	}
	defer os.Remove(f.Name())

	if _, err := f.WriteString(script); err != nil {
		f.Close()
		return fmt.Errorf("failed to write script: %w", err)
	}
	f.Close()

	if err := os.Chmod(f.Name(), 0o700); err != nil {
		return err
	}

	cmd := exec.Command(f.Name())
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

