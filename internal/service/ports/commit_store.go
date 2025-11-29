package ports

import "gitter/internal/domain"

type CommitStore interface {
	LoadLog() ([]domain.Commit, error)
	SaveLog([]domain.Commit) error
}
