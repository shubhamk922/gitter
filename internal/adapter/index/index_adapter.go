package index

import (
	"encoding/json"
	"gitter/internal/domain"
	"os"
)

type JSONIndexStore struct {
	path string
}

func NewJSONIndexStore(path string) *JSONIndexStore {
	return &JSONIndexStore{path}
}

func (s *JSONIndexStore) Load() (domain.Index, error) {
	data, err := os.ReadFile(s.path)
	if err != nil {
		return domain.Index{}, nil
	}
	var idx domain.Index
	json.Unmarshal(data, &idx)
	return idx, nil
}

func (s *JSONIndexStore) Save(index domain.Index) error {
	data, _ := json.MarshalIndent(index, "", "  ")
	return os.WriteFile(s.path, data, 0644)
}
