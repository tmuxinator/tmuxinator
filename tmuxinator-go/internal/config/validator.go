// Package config handles tmuxinator configuration file discovery and loading.
package config

import (
	"fmt"

	"github.com/tmuxinator/tmuxinator/internal/models"
)

// ValidateProject loads and validates a project, returning the validated project.
// This is the main entry point for the start/stop/debug commands.
func ValidateProject(opts ValidateOptions) (*models.Project, error) {
	result, err := Validate(opts)
	if err != nil {
		return nil, err
	}

	project, err := LoadProject(result.ProjectFile, result.Options)
	if err != nil {
		return nil, err
	}

	if err := project.Validate(); err != nil {
		return nil, fmt.Errorf("%w", err)
	}

	return project, nil
}

