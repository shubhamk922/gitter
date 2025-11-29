package fs

import (
	"os"
	"path/filepath"
)

type FSRepo struct{}

func NewFSRepo() *FSRepo {
	return &FSRepo{}
}

func (f *FSRepo) Exists(path string) bool {
	_, err := os.Stat(path)
	return err == nil
}

func (f *FSRepo) CreateDir(path string) error {
	return os.Mkdir(path, 0755)
}

func (f *FSRepo) WriteFile(path string, data []byte) error {
	return os.WriteFile(path, data, 0644)
}

func (f *FSRepo) GetAbs(path string) (string, error) {
	return filepath.Abs(path)
}
