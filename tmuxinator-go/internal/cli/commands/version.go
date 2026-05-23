// Package commands implements all tmuxinator CLI commands.
package commands

import (
	"fmt"

	"github.com/spf13/cobra"
)

// Version is the current tmuxinator version.
const Version = "4.0.0"

// NewVersionCmd creates the `version` command.
func NewVersionCmd() *cobra.Command {
	return &cobra.Command{
		Use:     "version",
		Short:   "Display installed tmuxinator version",
		Aliases: []string{"-v"},
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Printf("tmuxinator %s\n", Version)
		},
	}
}

