package ports

import "io/fs"

type FileSystem interface {
	Exists(path string) bool
	ReadFile(path string) ([]byte, error)
	WriteFile(path string, data []byte) error
	ReadDir(path string) ([]fs.DirEntry, error)
	Mkdir(path string) error
	Abs(path string) (string, error)
	Stat(path string) (fs.FileInfo, error)
}
