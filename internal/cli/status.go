package cli

import (
	"fmt"

	"gitter/internal/service"
)

func helpStatus() {
	fmt.Println("NAME:")
	fmt.Println("    gitter status - Show the working tree and staging area status")
	fmt.Println()
	fmt.Println("SYNOPSIS:")
	fmt.Println("    gitter status")
	fmt.Println()
	fmt.Println("DESCRIPTION:")
	fmt.Println("    Displays the status of files in the working directory relative to the staging area.")
	fmt.Println("    Shows new, modified, and staged files that are ready to be committed.")
}

func Status(svc *service.StatusUseCase) {
	svc.Execute()
}
