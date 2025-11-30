package service

import (
	"fmt"
	"gitter/internal/service/ports"
)

type StatusUseCase struct {
	fs     ports.FileSystem
	ignore ports.IgnorePatternLoader
	idxs   ports.IndexStore
	cms    ports.CommitStore
}

func NewStatusUseCase(
	fs ports.FileSystem,
	ignore ports.IgnorePatternLoader,
	idxs ports.IndexStore,
	cms ports.CommitStore,
) *StatusUseCase {
	return &StatusUseCase{fs, ignore, idxs, cms}
}

func (uc *StatusUseCase) Execute() {
	index, _ := uc.idxs.Load()
	commits, _ := uc.cms.LoadLog()

	// Staged
	if len(index.Staged) > 0 || len(index.Deleted) > 0 {
		fmt.Println("Changes to be committed:")
		for _, f := range index.Staged {
			fmt.Println("  new file:", f)
		}
		for _, f := range index.Deleted {
			fmt.Println("  remove file:", f)
		}
		return
	}

	// Modified
	if len(index.Modified) > 0 {
		fmt.Println("Changes not staged for commit:")
		for _, f := range index.Modified {
			fmt.Println("  modified:", f)
		}
		return
	}

	// Build tracked file set
	tracked := map[string]bool{}
	for _, c := range commits {
		for _, f := range c.Files {
			tracked[f] = true
		}
	}

	// Untracked
	entries, _ := uc.fs.ReadDir(".")
	var untracked []string

	for _, e := range entries {
		name := e.Name()

		if uc.ignore.ShouldIgnore(name) {
			continue
		}
		if e.IsDir() || name == ".gitter" {
			continue
		}
		if !tracked[name] {
			untracked = append(untracked, name)
		}
	}

	if len(untracked) == 0 {
		fmt.Println("nothing to commit, working tree clean")
		return
	}

	if len(untracked) > 0 {
		fmt.Println("Untracked files:")
		for _, f := range untracked {
			fmt.Println(" ", f)
		}
	}

}
