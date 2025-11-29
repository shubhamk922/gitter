package service

import (
	"fmt"
	"gitter/internal/service/ports"
)

type BranchService struct {
	branchStore ports.BranchStore
}

func NewBranchService(bs ports.BranchStore) *BranchService {
	return &BranchService{branchStore: bs}
}

func (s *BranchService) CreateBranch(name string) error {
	if s.branchStore.BranchExists(name) {
		return fmt.Errorf("branch already exists")
	}

	if err := s.branchStore.CreateBranch(name); err != nil {
		return err
	}

	if err := s.branchStore.SetHEAD(name); err != nil {
		return err
	}

	return nil
}
