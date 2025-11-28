package repo

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
)

func ensureRepo() bool {
	_, err := os.Stat(".gitter")
	return err == nil
}

func writeJSON(path string, v interface{}) error {
	f, err := os.Create(path)
	if err != nil {
		return err
	}
	defer f.Close()
	return json.NewEncoder(f).Encode(v)
}

func readJSON(path string, v interface{}) error {
	f, err := os.Open(path)
	if err != nil {
		return err
	}
	defer f.Close()
	return json.NewDecoder(f).Decode(v)
}

func loadIgnorePatterns() map[string]bool {
	data, err := os.ReadFile(".gitter/gitterignore")
	if err != nil {
		return map[string]bool{}
	}

	lines := strings.Split(string(data), "\n")
	ignore := map[string]bool{}

	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line != "" {
			ignore[line] = true
		}
	}

	return ignore
}

func shouldIgnore(file string, ignore map[string]bool) bool {
	base := filepath.Base(file)
	_, exists := ignore[base]
	return exists
}
