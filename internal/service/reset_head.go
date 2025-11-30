// service/reset_head.go
package service

import (
	"fmt"
	"gitter/internal/domain"
	"gitter/internal/service/ports"
	"strconv"
	"strings"
)

type ResetHeadUseCase struct {
	logs  ports.CommitStore
	index ports.IndexStore
}

func NewResetHeadUseCase(logs ports.CommitStore, index ports.IndexStore) *ResetHeadUseCase {
	return &ResetHeadUseCase{logs, index}
}

func (uc *ResetHeadUseCase) Execute(args []string) (string, error) {
	n := 1
	if len(args) > 2 {
		arg := args[2] // e.g. "HEAD~3"

		if strings.HasPrefix(arg, "HEAD~") {
			value := strings.TrimPrefix(arg, "HEAD~")

			parsed, err := strconv.Atoi(value)
			if err != nil || parsed < 1 {
				return "", fmt.Errorf("invalid reset target: %s", arg)
			}
			n = parsed
		}
	}

	logEntries, err := uc.logs.LoadLog()
	if err != nil {
		return "", err
	}

	total := len(logEntries)
	if total == 0 {
		return "Nothing to reset.", nil
	}

	// --------------------------------------------
	// 3. Validate that HEAD~n exists
	// --------------------------------------------
	if n >= total {
		return "", fmt.Errorf("cannot reset to HEAD~%d: only %d commits exist", n, total-1)
	}

	// last commit index before reset
	targetIndex := total - n - 1

	// --------------------------------------------
	// 4. Determine last commit and target commit
	// --------------------------------------------
	//lastCommit := logEntries[total-1]
	targetCommit := logEntries[targetIndex]

	// Remove last n commits
	newLog := logEntries[:targetIndex+1]

	if err := uc.logs.SaveLog(newLog); err != nil {
		return "", err
	}

	// --------------------------------------------
	// 5. Determine modified files (files present in removed commits but not in target)
	// --------------------------------------------

	// Build target commit file set
	targetSet := map[string]bool{}
	for _, f := range targetCommit.Files {
		targetSet[f] = true
	}

	// Collect all removed commits
	modifiedSet := map[string]bool{}
	for i := targetIndex + 1; i < total; i++ {
		c := logEntries[i]
		for _, f := range c.Files {
			if !targetSet[f] {
				modifiedSet[f] = true
			}
		}
	}

	modified := make([]string, 0, len(modifiedSet))
	for f := range modifiedSet {
		modified = append(modified, f)
	}

	// --------------------------------------------
	// 6. Update index (clear staged, set modified)
	// --------------------------------------------
	newIndex := domain.Index{
		Staged:   []string{},
		Modified: modified,
	}

	if err := uc.index.Save(newIndex); err != nil {
		return "", err
	}

	return fmt.Sprintf("HEAD reset to HEAD~%d.", n), nil

}
