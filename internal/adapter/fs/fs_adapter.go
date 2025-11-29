package fs

import (
	"io/fs"
	"os"
)

type OSFileSystem struct{}

func NewOSFileSystem() *OSFileSystem {
	return &OSFileSystem{}
}

func (o *OSFileSystem) Exists(path string) bool {
	_, err := os.Stat(path)
	return err == nil
}

func (o *OSFileSystem) ReadDir(path string) ([]fs.DirEntry, error) {
	return os.ReadDir(path)
}

func (o *OSFileSystem) ReadFile(path string) ([]byte, error) {
	return os.ReadFile(path)
}

func (o *OSFileSystem) WriteFile(path string, data []byte) error {
	return os.WriteFile(path, data, 0644)
}

func (o *OSFileSystem) Stat(path string) (fs.FileInfo, error) {
	return os.Stat(path)
}
