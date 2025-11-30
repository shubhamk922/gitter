package cmd

import (
	"fmt"
	"gitter/internal/adapter"
	cli "gitter/internal/cli"
	"gitter/internal/service"
	"os"
)

func Execute() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: gitter <command>")
		return
	}
	repoBase := ".gitter"

	branchRepo := adapter.NewFSBranchStore(repoBase)
	indexStore := adapter.NewJSONIndexStore(".gitter/index.json")
	commitStore := adapter.NewJSONCommitStore(".gitter/log.json")
	filesystem := adapter.NewOSFileSystem()
	patterns, _ := adapter.LoadIgnoreFromFile(repoBase + "/gitterignore") // you already have this
	ignore := adapter.NewIgnoreAdapter(patterns)

	initRepo := service.NewInitRepositoryUseCase(filesystem)
	addFiles := service.NewAddFilesUseCase(filesystem, ignore, indexStore)
	removeFiles := service.NewRemoveFilesUseCase(filesystem, ignore, indexStore)
	commitChanges := service.NewCommitUseCase(indexStore, commitStore)
	showStatus := service.NewStatusUseCase(filesystem, ignore, indexStore, commitStore)
	showLog := service.NewLogCommitsUseCase(commitStore)
	checkoutBranch := service.NewBranchService(branchRepo)
	resetHead := service.NewResetHeadUseCase(commitStore, indexStore)

	cmd := os.Args[1]

	switch cmd {
	case "help":
		if len(os.Args) == 3 {
			cli.HelpTopic(os.Args[2])
		} else {
			cli.Help()
		}
	case "init":
		cli.Init(repoBase, initRepo)
	case "add":
		cli.Add(os.Args[2:], addFiles)
	case "status":
		cli.Status(showStatus)
	case "commit":
		cli.Commit(os.Args[2:], commitChanges)
	case "log":
		cli.Log(showLog)
	case "reset":
		cli.ResetHead(os.Args, resetHead)
	case "checkout":
		cli.Checkout(os.Args[2:], checkoutBranch)
	case "rm":
		cli.Remove(os.Args[2:], removeFiles)
	default:
		fmt.Println("Unknown command:", cmd)
	}

}
