package service

import (
	"fmt"
	"gitter/internal/service/ports"
	"path/filepath"
)

type InitRepoService struct {
	FS ports.FileSystem
}

func NewInitRepositoryUseCase(fs ports.FileSystem) *InitRepoService {
	return &InitRepoService{FS: fs}
}

func (uc *InitRepoService) Execute(repoPath string) (string, error) {
	// STEP 1: Create .gitter directory
	if uc.FS.Exists(repoPath) {
		return "Reinitialized existing Gitter repository", nil
	}

	if err := uc.FS.Mkdir(repoPath); err != nil {
		return "", err
	}

	// STEP 2: Create gitterignore
	ignoreContent := []byte("gitter_test_results.txt\n")
	if err := uc.FS.WriteFile(
		filepath.Join(repoPath, "gitterignore"),
		ignoreContent,
	); err != nil {
		return "", fmt.Errorf("failed to create gitterignore: %v", err)
	}

	// STEP 3: Create index.json
	index := []byte(`{"staged":[]}`)
	uc.FS.WriteFile(filepath.Join(repoPath, "index.json"), index)

	// STEP 4: Final message
	abs, _ := uc.FS.Abs(repoPath)
	return fmt.Sprintf("Initialized empty Gitter repository in %s", abs), nil
}
