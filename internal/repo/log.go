package repo

import (
	"fmt"

	"gitter/internal/models"
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

func Log() {
	if !ensureRepo() {
		fmt.Println("Not a gitter repo")
		return
	}

	var commits []models.Commit
	readJSON(".gitter/log.json", &commits)

	if len(commits) == 0 {
		fmt.Println("your current branch does not have any commits yet")
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
