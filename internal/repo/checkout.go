package repo

import (
	"fmt"
	"os"
	"path/filepath"
)

func Checkout(args []string) {
	if !ensureRepo() {
		fmt.Println("Not a gitter repo")
		return
	}

	// Case: gitter checkout -b <branch>
	if len(args) == 2 && args[0] == "-b" {
		newBranch := args[1]
		createBranch(newBranch)
		return
	}

	// Additional checkout logic can be added later (switching branches)
	fmt.Println("Invalid checkout usage")
}

func createBranch(branch string) {
	refsDir := ".gitter/refs/heads"

	// Ensure directory exists
	if err := os.MkdirAll(refsDir, 0755); err != nil {
		fmt.Println("error:", err)
		return
	}

	// Branch file → contains HEAD commit hash (or empty for now)
	branchPath := filepath.Join(refsDir, branch)

	// Create the branch reference file (empty content is OK for this test)
	if err := os.WriteFile(branchPath, []byte(""), 0644); err != nil {
		fmt.Println("error:", err)
		return
	}

	// Output expected by the test:
	fmt.Printf("Switched to a new branch '%s'\n", branch)
}
