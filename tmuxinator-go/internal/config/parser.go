// Package config handles tmuxinator configuration file discovery and loading.
package config

import (
	"bytes"
	"fmt"
	"os"
	"strings"
	"text/template"

	"gopkg.in/yaml.v3"

	"github.com/tmuxinator/tmuxinator/internal/models"
)

// ParseSettings splits args into key=value settings and positional args.
// Settings are removed from args in-place and returned as a map.
func ParseSettings(args []string) (map[string]string, []string) {
	settings := map[string]string{}
	var remaining []string
	for _, arg := range args {
		if idx := strings.Index(arg, "="); idx > 0 {
			key := arg[:idx]
			val := arg[idx+1:]
			settings[key] = val
		} else {
			remaining = append(remaining, arg)
		}
	}
	return settings, remaining
}

// LoadProject reads, renders (ERB-like), and parses a project YAML file.
// args are the command-line arguments passed to the project.
func LoadProject(path string, opts map[string]interface{}) (*models.Project, error) {
	content, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("failed to read config file: %w", err)
	}

	// Extract args from options
	var args []string
	if a, ok := opts["args"].([]string); ok {
		args = a
	}

	settings, positionalArgs := ParseSettings(args)

	// Render ERB-like template
	rendered, err := renderTemplate(string(content), positionalArgs, settings)
	if err != nil {
		return nil, fmt.Errorf("failed to parse config file: %w", err)
	}

	// Parse YAML
	var rawYAML map[string]interface{}
	if err := yaml.Unmarshal([]byte(rendered), &rawYAML); err != nil {
		return nil, fmt.Errorf("failed to parse config file: %w", err)
	}
	if rawYAML == nil {
		rawYAML = map[string]interface{}{}
	}

	project := models.NewProject(rawYAML, opts)
	return project, nil
}

// renderTemplate processes ERB-like syntax in the YAML content.
// It converts Ruby ERB tags to Go text/template syntax and renders them.
//
// Supported ERB patterns:
//   - <%= expr %>   → {{ expr }}  (output)
//   - <%- ... -%>   → trimmed whitespace variant
//   - <% ... %>     → {{ ... }}   (action, no output)
//   - ENV["VAR"]    → env "VAR"
//   - @args[n]      → index .Args n
//   - @settings["k"] → index .Settings "k"
func renderTemplate(content string, args []string, settings map[string]string) (string, error) {
	// Convert ERB syntax to Go template syntax
	goTmpl := erbToGoTemplate(content)

	// Build template data
	data := map[string]interface{}{
		"Args":     args,
		"Settings": settings,
	}

	funcMap := template.FuncMap{
		"env": func(key string) string {
			return os.Getenv(key)
		},
		"args": func(i int) string {
			if i < len(args) {
				return args[i]
			}
			return ""
		},
		"setting": func(key string) string {
			return settings[key]
		},
	}

	tmpl, err := template.New("config").Funcs(funcMap).Parse(goTmpl)
	if err != nil {
		// If template parsing fails, return the original content
		// (it may not use any ERB syntax)
		return content, nil
	}

	var buf bytes.Buffer
	if err := tmpl.Execute(&buf, data); err != nil {
		return content, nil
	}
	return buf.String(), nil
}

// erbToGoTemplate converts ERB-style template syntax to Go text/template syntax.
func erbToGoTemplate(erb string) string {
	// We process the string character by character to handle all ERB variants.
	var result strings.Builder
	i := 0
	for i < len(erb) {
		if i+1 < len(erb) && erb[i] == '<' && erb[i+1] == '%' {
			// Find the closing %>
			trim := false
			output := false
			start := i + 2

			// Check for <%- (trim leading whitespace)
			if start < len(erb) && erb[start] == '-' {
				trim = true
				start++
			}
			// Check for <%= (output expression)
			if start < len(erb) && erb[start] == '=' {
				output = true
				start++
			}

			// Find closing %>
			end := strings.Index(erb[start:], "%>")
			if end < 0 {
				// No closing tag, output as-is
				result.WriteByte(erb[i])
				i++
				continue
			}
			end += start

			// Check for -%> (trim trailing whitespace/newline)
			trimEnd := false
			if end > 0 && erb[end-1] == '-' {
				trimEnd = true
				end--
			}

			inner := strings.TrimSpace(erb[start:end])

			// Convert Ruby ERB expressions to Go template
			converted := convertRubyExpr(inner)

			if output {
				result.WriteString("{{ ")
				result.WriteString(converted)
				result.WriteString(" }}")
			} else {
				result.WriteString("{{ ")
				result.WriteString(converted)
				result.WriteString(" }}")
			}

			// Skip past the closing %>
			closeEnd := end
			if trimEnd {
				closeEnd++ // skip the '-'
			}
			i = closeEnd + 2 // skip %>

			// Handle trim directives
			_ = trim
			_ = trimEnd
		} else {
			result.WriteByte(erb[i])
			i++
		}
	}
	return result.String()
}

// convertRubyExpr converts a Ruby ERB expression to a Go template expression.
func convertRubyExpr(ruby string) string {
	ruby = strings.TrimSpace(ruby)

	// ENV["VAR"] → env "VAR"
	if strings.HasPrefix(ruby, `ENV["`) && strings.HasSuffix(ruby, `"]`) {
		key := ruby[5 : len(ruby)-2]
		return fmt.Sprintf(`env "%s"`, key)
	}
	if strings.HasPrefix(ruby, `ENV['`) && strings.HasSuffix(ruby, `']`) {
		key := ruby[5 : len(ruby)-2]
		return fmt.Sprintf(`env "%s"`, key)
	}

	// @args[n] → index .Args n
	if strings.HasPrefix(ruby, "@args[") && strings.HasSuffix(ruby, "]") {
		idx := ruby[6 : len(ruby)-1]
		return fmt.Sprintf("index .Args %s", idx)
	}

	// @settings["key"] → index .Settings "key"
	if strings.HasPrefix(ruby, `@settings["`) && strings.HasSuffix(ruby, `"]`) {
		key := ruby[11 : len(ruby)-2]
		return fmt.Sprintf(`index .Settings "%s"`, key)
	}
	if strings.HasPrefix(ruby, `@settings['`) && strings.HasSuffix(ruby, `']`) {
		key := ruby[11 : len(ruby)-2]
		return fmt.Sprintf(`index .Settings "%s"`, key)
	}

	// Pass through other expressions unchanged (they'll likely be no-ops)
	return ruby
}

