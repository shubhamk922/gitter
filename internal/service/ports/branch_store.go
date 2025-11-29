package ports

type BranchStore interface {
	CreateBranch(name string) error
	BranchExists(name string) bool
	SetHEAD(branchName string) error
	GetHEAD() (string, error)
}
