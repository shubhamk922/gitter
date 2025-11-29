package repo

import (
	"fmt"
	"gitter/internal/service"
)

func Checkout(args []string, branchService *service.BranchService) {
	if !ensureRepo() {
		fmt.Println("Not a gitter repo")
		return
	}

	// Case: gitter checkout -b <branch>
	if len(args) == 2 && args[0] == "-b" {
		branch := args[1]
		if err := branchService.CreateBranch(branch); err != nil {
			fmt.Println("Error:", err)
			return
		}

		fmt.Printf("Switched to a new branch '%s'\n", branch)
		return
	}

	// Additional checkout logic can be added later (switching branches)
	fmt.Println("Invalid checkout usage")
}
