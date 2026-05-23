// Package util provides file-related utility functions for tmuxinator.
package util

import (
	"io"
	"os"
	"path/filepath"
)

// FileExists returns true if the given path exists and is a regular file.
func FileExists(path string) bool {
	info, err := os.Stat(path)
	if err != nil {
		return false
	}
	return info.Mode().IsRegular()
}

// DirExists returns true if the given path exists and is a directory.
func DirExists(path string) bool {
	info, err := os.Stat(path)
	if err != nil {
		return false
	}
	return info.IsDir()
}

// EnsureDir creates the directory (and all parents) if it does not exist.
func EnsureDir(path string) error {
	return os.MkdirAll(path, 0o755)
}

// CopyFile copies the file at src to dst, creating dst if it doesn't exist.
func CopyFile(src, dst string) error {
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()

	if err := EnsureDir(filepath.Dir(dst)); err != nil {
		return err
	}

	out, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer out.Close()

	_, err = io.Copy(out, in)
	return err
}

// ReadFile reads and returns the contents of the file at path.
func ReadFile(path string) (string, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return "", err
	}
	return string(data), nil
}

// WriteFile writes content to the file at path, creating it if necessary.
func WriteFile(path, content string) error {
	if err := EnsureDir(filepath.Dir(path)); err != nil {
		return err
	}
	return os.WriteFile(path, []byte(content), 0o644)
}

// GlobYAML returns all *.yml and *.yaml files under dir (recursive).
func GlobYAML(dir string) ([]string, error) {
	var results []string
	err := filepath.WalkDir(dir, func(path string, d os.DirEntry, err error) error {
		if err != nil {
			return nil // skip unreadable entries
		}
		if d.IsDir() {
			return nil
		}
		ext := filepath.Ext(path)
		if ext == ".yml" || ext == ".yaml" {
			results = append(results, path)
		}
		return nil
	})
	return results, err
}

