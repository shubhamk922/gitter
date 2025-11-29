package service

import (
	"fmt"
	"gitter/internal/service/ports"
	"path/filepath"
)

type InitRepoService struct {
	FS ports.RepoStore
}

func NewInitRepositoryUseCase(fs ports.RepoStore) *InitRepoService {
	return &InitRepoService{FS: fs}
}

func (uc *InitRepoService) Execute(repoPath string) (string, error) {
	// STEP 1: Create .gitter directory
	if uc.FS.Exists(repoPath) {
		return "Reinitialized existing Gitter repository", nil
	}

	if err := uc.FS.CreateDir(repoPath); err != nil {
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
	abs, _ := uc.FS.GetAbs(repoPath)
	return fmt.Sprintf("Initialized empty Gitter repository in %s", abs), nil
}
