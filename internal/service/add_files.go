package service

import (
	"gitter/internal/service/ports"
)

type AddFilesUseCase struct {
	FS        ports.FileSystem
	Ignore    ports.IgnorePatternLoader
	IndexRepo ports.IndexStore
}

func NewAddFilesUseCase(
	fs ports.FileSystem,
	ignore ports.IgnorePatternLoader,
	indexRepo ports.IndexStore,
) *AddFilesUseCase {
	return &AddFilesUseCase{FS: fs, Ignore: ignore, IndexRepo: indexRepo}
}

func (uc *AddFilesUseCase) Execute(files []string) error {

	index, _ := uc.IndexRepo.Load()

	// Case 1: add .
	if len(files) == 1 && files[0] == "." {
		entries, _ := uc.FS.ReadDir(".")
		for _, e := range entries {
			name := e.Name()

			if e.IsDir() || name == ".gitter" {
				continue
			}
			if uc.Ignore.ShouldIgnore(name) {
				continue
			}
			index.Staged = append(index.Staged, name)
		}

		return uc.IndexRepo.Save(index)
	}

	// Case 2: add specific files
	for _, f := range files {
		if _, err := uc.FS.Stat(f); err == nil {
			if uc.Ignore.ShouldIgnore(f) {
				continue
			}
			index.Staged = append(index.Staged, f)
		}
	}

	return uc.IndexRepo.Save(index)
}
