package repo

import (
	"fmt"

	"gitter/internal/service"
)

func helpCommit() {
	fmt.Println("NAME:")
	fmt.Println("    gitter commit - Record changes to the repository")
	fmt.Println()
	fmt.Println("SYNOPSIS:")
	fmt.Println("    gitter commit -m <message>")
	fmt.Println()
	fmt.Println("DESCRIPTION:")
	fmt.Println("    Creates a new commit containing the staged changes from the index.")
	fmt.Println("    A commit message is required and must be provided using the -m option.")
}

func Commit(args []string, svc *service.CommitUseCase) {
	if !ensureRepo() {
		fmt.Println("Not a gitter repo")
		return
	}

	// extract message
	msg := ""
	for i := 0; i < len(args); i++ {
		if args[i] == "-m" && i+1 < len(args) {
			msg = args[i+1]
		}
	}

	_, err := svc.Commit(msg)
	if err != nil {
		if err == service.ErrNothingToCommit {
			fmt.Println("nothing to commit")
		} else {
			fmt.Println("commit error:", err)
		}
		return
	}

	fmt.Println("Committed:", msg)

}
