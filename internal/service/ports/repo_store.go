package ports

type RepoStore interface {
	Exists(path string) bool
	CreateDir(path string) error
	WriteFile(path string, data []byte) error
	GetAbs(path string) (string, error)
}
