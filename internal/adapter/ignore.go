package adapter

import (
	"bufio"
	"os"
	"strings"
)

type IgnoreAdapter struct {
	Patterns []string
}

func NewIgnoreAdapter(patterns []string) *IgnoreAdapter {
	return &IgnoreAdapter{Patterns: patterns}
}

func (i *IgnoreAdapter) LoadIgnorePatterns() []string {
	return i.Patterns
}

func (i *IgnoreAdapter) ShouldIgnore(file string) bool {
	for _, p := range i.Patterns {
		if strings.TrimSpace(p) == file {
			return true
		}
	}
	return false
}

func LoadIgnoreFromFile(path string) ([]string, error) {

	data, err := os.Open(path)
	if err != nil {
		// If no ignore file, return empty list, NOT an error
		if os.IsNotExist(err) {
			return []string{}, nil
		}
		return nil, err
	}
	defer data.Close()

	var patterns []string
	scanner := bufio.NewScanner(data)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())

		// skip empty lines & comments
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		patterns = append(patterns, line)
	}

	return patterns, scanner.Err()
}
