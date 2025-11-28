package cmd

import (
	"fmt"
	"gitter/internal/repo"
	"os"
)

func Execute() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: gitter <command>")
		return
	}

	cmd := os.Args[1]

	switch cmd {
	case "help":
		if len(os.Args) == 3 {
			repo.HelpTopic(os.Args[2])
		} else {
			repo.Help()
		}
		repo.Help()
	case "init":
		repo.Init()
	case "add":
		repo.Add(os.Args[2:])
	case "status":
		repo.Status()
	case "commit":
		repo.Commit(os.Args[2:])
	case "log":
		repo.Log()
	case "reset":
		if len(os.Args) > 2 && os.Args[2] == "HEAD~1" {
			repo.ResetHead()
		}
	case "checkout":
		repo.Checkout(os.Args[2:])

	default:
		fmt.Println("Unknown command:", cmd)
	}

}
