package fs

import (
	"gitter/internal/service/ports"
	"os"
	"path/filepath"
)

type FSBranchStore struct {
	base string
}

func NewFSBranchStore(basePath string) ports.BranchStore {
	return &FSBranchStore{base: basePath}
}

func (s *FSBranchStore) branchPath(name string) string {
	return filepath.Join(s.base, "refs", "heads", name)
}

func (s *FSBranchStore) BranchExists(name string) bool {
	_, err := os.Stat(s.branchPath(name))
	return err == nil
}

func (s *FSBranchStore) CreateBranch(name string) error {
	dir := filepath.Join(s.base, "refs", "heads")
	if err := os.MkdirAll(dir, 0755); err != nil {
		return err
	}
	return os.WriteFile(s.branchPath(name), []byte(""), 0644)
}

func (s *FSBranchStore) SetHEAD(name string) error {
	headPath := filepath.Join(s.base, "HEAD")
	return os.WriteFile(headPath, []byte(name), 0644)
}

func (s *FSBranchStore) GetHEAD() (string, error) {
	headPath := filepath.Join(s.base, "HEAD")
	data, err := os.ReadFile(headPath)
	if err != nil {
		return "", err
	}
	return string(data), nil
}
