package repo

import (
	"crypto/sha1"
	"encoding/hex"
	"fmt"
	"time"

	"gitter/internal/models"
)

func helpCommit() {
	fmt.Println("NAME:")
	fmt.Println("    gitter commit - Record changes to the repository")
	fmt.Println()
	fmt.Println("SYNOPSIS:")
	fmt.Println("    gitter commit -m <message>")
	fmt.Println()
	fmt.Println("DESCRIPTION:")
	fmt.Println("    Creates a new commit containing the staged changes from the index.")
	fmt.Println("    A commit message is required and must be provided using the -m option.")
}

func Commit(args []string) {
	if !ensureRepo() {
		fmt.Println("Not a gitter repo")
		return
	}

	index := models.Index{}
	readJSON(".gitter/index.json", &index)

	if len(index.Staged) == 0 {
		fmt.Println("nothing to commit")
		return
	}

	// extract message
	msg := ""
	for i := 0; i < len(args); i++ {
		if args[i] == "-m" && i+1 < len(args) {
			msg = args[i+1]
		}
	}

	// generate commit hash
	h := sha1.New()
	h.Write([]byte(time.Now().String() + msg))
	hash := hex.EncodeToString(h.Sum(nil))

	commit := models.Commit{
		Hash:    hash,
		Message: msg,
		Author:  "user",
		Date:    time.Now().Format(time.RFC1123),
		Files:   index.Staged,
	}

	// append commit
	var commits []models.Commit
	readJSON(".gitter/log.json", &commits)
	commits = append(commits, commit)
	writeJSON(".gitter/log.json", commits)

	// clear staging
	index.Staged = []string{}
	writeJSON(".gitter/index.json", index)

	fmt.Println("Committed:", msg)
}
