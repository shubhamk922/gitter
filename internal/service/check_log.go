package service

import (
	"errors"
	"gitter/internal/domain"
	"gitter/internal/service/ports"
)

var ErrNoCommits = errors.New("no commits found")

type LogCommitsUseCase struct {
	CommitRepo ports.CommitStore
}

func NewLogCommitsUseCase(commitRepo ports.CommitStore) *LogCommitsUseCase {
	return &LogCommitsUseCase{CommitRepo: commitRepo}
}

func (uc *LogCommitsUseCase) GetLogs() ([]domain.Commit, error) {

	commits, err := uc.CommitRepo.LoadLog()
	if err != nil {
		return nil, err
	}

	if len(commits) == 0 {
		return nil, ErrNoCommits
	}

	return commits, nil
}
