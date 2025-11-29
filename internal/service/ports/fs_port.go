package ports

import "io/fs"

type FileSystem interface {
	Exists(path string) bool
	ReadDir(path string) ([]fs.DirEntry, error)
	ReadFile(path string) ([]byte, error)
	WriteFile(path string, data []byte) error
	Stat(path string) (fs.FileInfo, error)
}
