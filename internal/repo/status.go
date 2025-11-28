package repo

import (
	"fmt"
	"os"

	"gitter/internal/models"
)

func helpStatus() {
	fmt.Println("NAME:")
	fmt.Println("    gitter status - Show the working tree and staging area status")
	fmt.Println()
	fmt.Println("SYNOPSIS:")
	fmt.Println("    gitter status")
	fmt.Println()
	fmt.Println("DESCRIPTION:")
	fmt.Println("    Displays the status of files in the working directory relative to the staging area.")
	fmt.Println("    Shows new, modified, and staged files that are ready to be committed.")
}

func Status() {
	if !ensureRepo() {
		fmt.Println("Not a gitter repo")
		return
	}

	index := models.Index{}
	readJSON(".gitter/index.json", &index)

	ignore := loadIgnorePatterns()

	if len(index.Staged) > 0 {
		fmt.Println("Changes to be committed:")
		for _, f := range index.Staged {
			fmt.Println("  new file:", f)
		}
		return
	}
	if len(index.Modified) > 0 {
		fmt.Println("Changes not staged for commit:")
		for _, f := range index.Modified {
			fmt.Println("  modified:", f)
		}
		return
	}
	var commits []models.Commit
	readJSON(".gitter/log.json", &commits)
	trackedSet := make(map[string]bool)
	for _, commit := range commits {
		for _, t := range commit.Files {
			trackedSet[t] = true
		}
	}
	// untracked files
	entries, _ := os.ReadDir(".")
	untracked := []string{}

	for _, e := range entries {
		name := e.Name()

		// Skip internal repo folder
		if name == ".gitter" {
			continue
		}

		// Skip directories
		if e.IsDir() {
			continue
		}

		//  Skip ignored files
		if shouldIgnore(name, ignore) {
			continue
		}
		if !trackedSet[name] {
			untracked = append(untracked, name)
		}
	}

	if len(untracked) == 0 {
		fmt.Println("nothing to commit, working tree clean")
		return
	}

	// Print untracked files
	fmt.Println("Untracked files:")
	for _, f := range untracked {
		fmt.Println(" ", f)
	}
}
