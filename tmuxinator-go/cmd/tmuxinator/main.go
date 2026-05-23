// Command tmuxinator is a Go rewrite of the tmuxinator Ruby gem.
// It manages complex tmux sessions using YAML configuration files.
package main

import (
	"os"

	"github.com/tmuxinator/tmuxinator/internal/cli"
)

func main() {
	cli.Bootstrap(os.Args[1:])
}

