// Package commands implements all tmuxinator CLI commands.
package commands

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"

	"github.com/tmuxinator/tmuxinator/internal/config"
	"github.com/tmuxinator/tmuxinator/internal/util"
)

// NewCopyCmd creates the `copy` command.
func NewCopyCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:     "copy [EXISTING] [NEW]",
		Short:   "Copy an existing project to a new project and open it in your editor",
		Aliases: []string{"c", "cp"},
		RunE: func(cmd *cobra.Command, args []string) error {
			if len(args) < 2 {
				return cmd.Help()
			}
			existing := args[0]
			newName := args[1]
			return runCopy(existing, newName)
		},
	}
	return cmd
}

func runCopy(existing, newName string) error {
	if !config.Exist(existing, "") {
		return fmt.Errorf("project %s doesn't exist", existing)
	}

	existingPath := config.Project(existing)
	newPath := config.DefaultProject(newName)

	if config.Exist(newName, "") {
		fmt.Printf("%s already exists, would you like to overwrite it? (y/n): ", newName)
		var answer string
		fmt.Scanln(&answer)
		if answer != "y" && answer != "Y" {
			return nil
		}
		fmt.Printf("Overwriting %s\n", newName)
	}

	if err := util.CopyFile(existingPath, newPath); err != nil {
		return fmt.Errorf("failed to copy project: %w", err)
	}

	return util.RunEditor(newPath)
}

// NewDeleteCmd creates the `delete` command.
func NewDeleteCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:     "delete [PROJECT1] [PROJECT2] ...",
		Short:   "Deletes given project(s)",
		Aliases: []string{"d", "rm"},
		RunE: func(cmd *cobra.Command, args []string) error {
			if len(args) == 0 {
				return cmd.Help()
			}
			return runDelete(args)
		},
	}
	return cmd
}

func runDelete(projects []string) error {
	for _, name := range projects {
		if !config.Exist(name, "") {
			fmt.Printf("%s does not exist!\n", name)
			continue
		}

		path := config.Project(name)
		fmt.Printf("Are you sure you want to delete %s? (y/n): ", name)
		var answer string
		fmt.Scanln(&answer)
		if answer != "y" && answer != "Y" {
			continue
		}

		if err := os.Remove(path); err != nil {
			fmt.Fprintf(os.Stderr, "Failed to delete %s: %v\n", name, err)
			continue
		}
		fmt.Printf("Deleted %s\n", name)
	}
	return nil
}

// NewImplodeCmd creates the `implode` command.
func NewImplodeCmd() *cobra.Command {
	return &cobra.Command{
		Use:     "implode",
		Short:   "Deletes all tmuxinator projects",
		Aliases: []string{"i"},
		RunE: func(cmd *cobra.Command, args []string) error {
			fmt.Print("Are you sure you want to delete all tmuxinator configs? (y/n): ")
			var answer string
			fmt.Scanln(&answer)
			if answer != "y" && answer != "Y" {
				return nil
			}

			for _, dir := range config.Directories() {
				if err := os.RemoveAll(dir); err != nil {
					fmt.Fprintf(os.Stderr, "Failed to remove %s: %v\n", dir, err)
				}
			}
			fmt.Println("Deleted all tmuxinator projects.")
			return nil
		},
	}
}

