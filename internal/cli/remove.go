package cli

import (
	"fmt"
	"gitter/internal/service"
)

func helpRemove() {
	fmt.Println("NAME:")
	fmt.Println("    gitter add - Add file contents to the staging area")
	fmt.Println()
	fmt.Println("SYNOPSIS:")
	fmt.Println("    gitter add <file1> <file2> ...")
	fmt.Println()
	fmt.Println("DESCRIPTION:")
	fmt.Println("    Adds one or more files to the Gitter staging index.")
	fmt.Println("    The files will be recorded in the .gitter/index file and included in the next commit.")
}

func Remove(files []string, service *service.RemoveFilesUseCase) {
	service.Execute(files)
}
