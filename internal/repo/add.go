package repo

import (
	"fmt"
	"gitter/internal/models"
	"os"
)

func helpAdd() {
	fmt.Println("NAME:")
	fmt.Println("    gitter add - Add file contents to the staging area")
	fmt.Println()
	fmt.Println("SYNOPSIS:")
	fmt.Println("    gitter add <file1> <file2> ...")
	fmt.Println()
	fmt.Println("DESCRIPTION:")
	fmt.Println("    Adds one or more files to the Gitter staging index.")
	fmt.Println("    The files will be recorded in the .gitter/index file and included in the next commit.")
}

func Add(files []string) {
	if !ensureRepo() {
		fmt.Println("Not a gitter repo")
		return
	}

	indexPath := ".gitter/index.json"
	index := models.Index{}

	readJSON(indexPath, &index)

	ignore := loadIgnorePatterns()

	// default: add .
	if len(files) == 1 && files[0] == "." {
		entries, _ := os.ReadDir(".")
		for _, e := range entries {
			if e.IsDir() || e.Name() == ".gitter" {
				continue
			}
			if shouldIgnore(e.Name(), ignore) {
				continue
			}

			index.Staged = append(index.Staged, e.Name())
		}
		writeJSON(indexPath, index)
		return
	}

	// add specific files
	for _, f := range files {
		if _, err := os.Stat(f); err == nil {
			if shouldIgnore(f, ignore) {
				continue
			}

			index.Staged = append(index.Staged, f)
		}
	}

	writeJSON(indexPath, index)
}
