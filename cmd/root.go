package cmd

import (
	"fmt"
	"gitter/internal/adapter"
	"gitter/internal/adapter/commit"
	"gitter/internal/adapter/fs"
	"gitter/internal/adapter/index"
	"gitter/internal/repo"
	"gitter/internal/service"
	"os"
)

func Execute() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: gitter <command>")
		return
	}
	repoBase := ".gitter"

	branchStore := fs.NewFSBranchStore(repoBase)
	idx := index.NewJSONIndexStore(".gitter/index.json")
	cms := commit.NewJSONCommitStore(".gitter/log.json")
	fsAdapter := fs.NewFSRepo()
	fs := fs.NewOSFileSystem()
	patterns, _ := adapter.LoadIgnoreFromFile() // you already have this
	ignore := adapter.NewIgnoreAdapter(patterns)

	branchService := service.NewBranchService(branchStore)
	initRepoService := service.NewInitRepositoryUseCase(fsAdapter)

	uc := service.NewAddFilesUseCase(fs, ignore, idx)

	commitsvc := service.NewCommitUseCase(idx, cms)

	statussvc := service.NewStatusUseCase(fs, ignore, idx, cms)

	logsvc := service.NewLogCommitsUseCase(cms)

	resetsvc := service.NewResetHeadUseCase(cms, idx)

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
		repo.Init(repoBase, initRepoService)
	case "add":
		repo.Add(os.Args[2:], uc)
	case "status":
		repo.Status(statussvc)
	case "commit":
		repo.Commit(os.Args[2:], commitsvc)
	case "log":
		repo.Log(logsvc)
	case "reset":
		repo.ResetHead(os.Args, resetsvc)
	case "checkout":
		repo.Checkout(os.Args[2:], branchService)
	default:
		fmt.Println("Unknown command:", cmd)
	}

}
