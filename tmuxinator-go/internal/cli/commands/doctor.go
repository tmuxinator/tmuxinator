// Package commands implements all tmuxinator CLI commands.
package commands

import (
	"fmt"

	"github.com/spf13/cobra"

	"github.com/tmuxinator/tmuxinator/internal/doctor"
)

// NewDoctorCmd creates the `doctor` command.
func NewDoctorCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "doctor",
		Short: "Look for problems in your configuration",
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Print("Checking if tmux is installed ==> ")
			yesNo(doctor.Installed())

			fmt.Print("Checking if $EDITOR is set ==> ")
			yesNo(doctor.EditorSet())

			fmt.Print("Checking if $SHELL is set ==> ")
			yesNo(doctor.ShellSet())
		},
	}
}

func yesNo(condition bool) {
	if condition {
		fmt.Println("\033[32mYes\033[0m")
	} else {
		fmt.Println("\033[31mNo\033[0m")
	}
}

