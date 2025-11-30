package service

import (
	"crypto/sha1"
	"encoding/hex"
	"errors"
	"gitter/internal/domain"
	"gitter/internal/service/ports"
	"time"
)

type CommitUseCase struct {
	IndexRepo  ports.IndexStore
	CommitRepo ports.CommitStore
}

var ErrNothingToCommit = errors.New("nothing to commit")

func NewCommitUseCase(indexRepo ports.IndexStore, commitRepo ports.CommitStore) *CommitUseCase {
	return &CommitUseCase{IndexRepo: indexRepo, CommitRepo: commitRepo}
}

func (uc *CommitUseCase) Commit(message string) (string, error) {

	// Load index
	idx, err := uc.IndexRepo.Load()
	if err != nil {
		return "", err
	}

	if len(idx.Staged) == 0 && len(idx.Deleted) == 0 {
		return "", ErrNothingToCommit
	}

	// Generate commit hash
	h := sha1.New()
	h.Write([]byte(time.Now().String() + message))
	hash := hex.EncodeToString(h.Sum(nil))

	commit := domain.Commit{
		Hash:    hash,
		Message: message,
		Author:  "user",
		Date:    time.Now().Format(time.RFC1123),
		Files:   idx.Staged,
		Deleted: idx.Deleted,
	}
	commits, err := uc.CommitRepo.LoadLog()
	if err != nil {
		return "", err
	}
	commits = append(commits, commit)

	// Save commit
	err = uc.CommitRepo.SaveLog(commits)
	if err != nil {
		return "", err
	}

	// Clear staging
	idx.Staged = []string{}
	idx.Deleted = []string{}
	err = uc.IndexRepo.Save(idx)
	if err != nil {
		return "", err
	}

	return hash, nil
}
