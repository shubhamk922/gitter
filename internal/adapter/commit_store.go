package adapter

import (
	"encoding/json"
	"os"

	"gitter/internal/domain"
)

type JSONCommitStore struct {
	path string
}

func NewJSONCommitStore(path string) *JSONCommitStore {
	return &JSONCommitStore{path}
}

func (s *JSONCommitStore) LoadLog() ([]domain.Commit, error) {
	if _, err := os.Stat(s.path); os.IsNotExist(err) {
		return []domain.Commit{}, nil
	}

	data, _ := os.ReadFile(s.path)
	var commits []domain.Commit
	json.Unmarshal(data, &commits)
	return commits, nil
}

func (r *JSONCommitStore) SaveLog(c []domain.Commit) error {
	data, _ := json.MarshalIndent(c, "", "  ")
	return os.WriteFile(r.path, data, 0644)
}
