package cli

import (
	"fmt"
	"gitter/internal/service"
)

func helpInit() {
	fmt.Println("NAME:")
	fmt.Println("    gitter init - Initialize a new Gitter repository")
	fmt.Println()
	fmt.Println("SYNOPSIS:")
	fmt.Println("    gitter init")
	fmt.Println()
	fmt.Println("DESCRIPTION:")
	fmt.Println("    Creates a new empty Gitter repository by setting up the .gitter directory.")
	fmt.Println("    This directory will contain internal files such as HEAD, refs, objects, and index.")
}

func Init(repoPath string, initService *service.InitRepoService) {
	message, err := initService.Execute(repoPath)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	fmt.Println(message)
}
