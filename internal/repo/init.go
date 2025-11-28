package repo

import (
	"fmt"
	"os"
	"path/filepath"
)

func helpInit() {
	fmt.Println("NAME:")
	fmt.Println("    gitter init - Initialize a new Gitter repository")
	fmt.Println()
	fmt.Println("SYNOPSIS:")
	fmt.Println("    gitter init")
	fmt.Println()
	fmt.Println("DESCRIPTION:")
	fmt.Println("    Creates a new empty Gitter repository by setting up the .gitter directory.")
	fmt.Println("    This directory will contain internal files such as HEAD, refs, objects, and index.")
}

func Init() {
	path := ".gitter"

	// STEP 1: create .gitter directory first
	err := os.Mkdir(path, 0755)
	if err != nil {
		if os.IsExist(err) {
			fmt.Println("Reinitialized existing Gitter repository")
		} else {
			fmt.Println("Error:", err)
		}
		return
	}

	// STEP 2: now create gitterignore INSIDE .gitter
	ignoreContent := "gitter_test_results.txt\n"
	if err := os.WriteFile(filepath.Join(path, "gitterignore"), []byte(ignoreContent), 0644); err != nil {
		fmt.Printf("failed to create gitterignore: %v\n", err)
		return
	}

	// STEP 3: (Optional but recommended) create index.json
	os.WriteFile(filepath.Join(path, "index.json"), []byte(`{"staged":[]}`), 0644)

	// Final expected message
	abs, _ := filepath.Abs(path)
	fmt.Printf("Initialized empty Gitter repository in %s\n", abs)
}
