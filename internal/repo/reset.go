package repo

import (
	"fmt"
	"gitter/internal/models"
)

func ResetHead() {
	if !ensureRepo() {
		fmt.Println("Not a gitter repo")
		return
	}

	logPath := ".gitter/log.json"
	indexPath := ".gitter/index.json"

	var logEntries []models.Commit
	readJSON(logPath, &logEntries)

	if len(logEntries) < 2 {
		fmt.Println("Nothing to reset.")
		return
	}

	// last commit → to be undone
	last := logEntries[len(logEntries)-1]
	// previous commit → to restore
	prev := logEntries[len(logEntries)-2]

	// Step 1: Remove last commit from log
	logEntries = logEntries[:len(logEntries)-1]
	writeJSON(logPath, logEntries)

	// Step 2: Working directory state change
	// Files added in last commit should appear as modified

	// Build a set of files from prev commit (clean ones)
	prevSet := map[string]bool{}
	for _, f := range prev.Files {
		prevSet[f] = true
	}

	// Build modified list:
	modified := []string{}
	for _, f := range last.Files {
		if !prevSet[f] {
			modified = append(modified, f)
		}
	}

	// Step 3: Update index.json → modified (unstaged)
	index := models.Index{
		Staged:   []string{},
		Modified: modified,
		// Untracked is not touched
	}
	writeJSON(indexPath, index)

}
