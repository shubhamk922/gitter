package cli

import (
	"fmt"

	"gitter/internal/service"
)

func helpLog() {
	fmt.Println("NAME:")
	fmt.Println("    gitter log - Show commit history")
	fmt.Println()
	fmt.Println("SYNOPSIS:")
	fmt.Println("    gitter log")
	fmt.Println()
	fmt.Println("DESCRIPTION:")
	fmt.Println("    Prints the sequence of commits starting from the current branch head.")
	fmt.Println("    Each commit entry shows the commit hash, author, date, and commit message.")
}

func Log(svc *service.LogCommitsUseCase) {
	if !ensureRepo() {
		fmt.Println("Not a gitter repo")
		return
	}

	commits, err := svc.GetLogs()
	if err != nil {
		if err == service.ErrNoCommits {
			fmt.Println("your current branch does not have any commits yet")
		} else {
			fmt.Println("error:", err)
		}
		return
	}

	for _, c := range commits {
		fmt.Println("commit", c.Hash)
		fmt.Println("Author:", c.Author)
		fmt.Println("Date:", c.Date)
		fmt.Println(" ", c.Message)
		fmt.Println()
	}
}
