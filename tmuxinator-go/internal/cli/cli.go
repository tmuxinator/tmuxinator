// Package cli sets up the Cobra command tree for tmuxinator.
package cli

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"

	"github.com/tmuxinator/tmuxinator/internal/cli/commands"
	"github.com/tmuxinator/tmuxinator/internal/config"
)

// NewRootCmd builds and returns the root Cobra command.
func NewRootCmd() *cobra.Command {
	root := &cobra.Command{
		Use:   "tmuxinator",
		Short: "Manage complex tmux sessions easily",
		Long: `tmuxinator creates and manages tmux sessions easily using YAML config files.

If a project name is given as the first argument and it matches an existing
project, it is treated as a shorthand for 'tmuxinator start <project>'.`,
		// Disable the default completion command
		CompletionOptions: cobra.CompletionOptions{
			DisableDefaultCmd: true,
		},
		// Custom arg handling: bare project names start sessions
		RunE: func(cmd *cobra.Command, args []string) error {
			if len(args) == 0 {
				if config.IsLocal() {
					return runLocalStart()
				}
				return cmd.Help()
			}
			// If first arg is a known project, start it
			name := args[0]
			if config.Exist(name, "") {
				startCmd := commands.NewStartCmd()
				startCmd.SetArgs(args)
				return startCmd.Execute()
			}
			return cmd.Help()
		},
	}

	// Register all sub-commands
	root.AddCommand(
		commands.NewStartCmd(),
		commands.NewStopCmd(),
		commands.NewStopAllCmd(),
		commands.NewLocalCmd(),
		commands.NewDebugCmd(),
		commands.NewNewCmd(),
		commands.NewEditCmd(),
		commands.NewCopyCmd(),
		commands.NewDeleteCmd(),
		commands.NewImplodeCmd(),
		commands.NewListCmd(),
		commands.NewCommandsCmd(),
		commands.NewCompletionsCmd(),
		commands.NewDoctorCmd(),
		commands.NewVersionCmd(),
	)

	return root
}

// Bootstrap is the main entry point, mirroring Ruby's Cli.bootstrap.
// It handles the special case where a bare project name is given.
func Bootstrap(args []string) {
	root := NewRootCmd()

	// If no args and a local project exists, run local
	if len(args) == 0 && config.IsLocal() {
		if err := runLocalStart(); err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		return
	}

	// If first arg is a known project name (not a subcommand), start it
	reservedCommands := reservedCommandNames(root)
	if len(args) > 0 {
		name := args[0]
		if !reservedCommands[name] && config.Exist(name, "") {
			// Treat as: tmuxinator start <args...>
			startArgs := append([]string{"start"}, args...)
			root.SetArgs(startArgs)
			if err := root.Execute(); err != nil {
				os.Exit(1)
			}
			return
		}
	}

	root.SetArgs(args)
	if err := root.Execute(); err != nil {
		os.Exit(1)
	}
}

// reservedCommandNames returns a set of all registered command names and aliases.
func reservedCommandNames(root *cobra.Command) map[string]bool {
	reserved := map[string]bool{
		"-v":   true,
		"help": true,
	}
	for _, cmd := range root.Commands() {
		reserved[cmd.Name()] = true
		for _, alias := range cmd.Aliases() {
			reserved[alias] = true
		}
	}
	return reserved
}

func runLocalStart() error {
	localCmd := commands.NewLocalCmd()
	return localCmd.RunE(localCmd, nil)
}

