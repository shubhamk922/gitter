package repo

import "fmt"

func Help() {
	fmt.Println("Gitter - a minimal git-like version control system")
	fmt.Println()
	fmt.Println("Usage:")
	fmt.Println("  gitter <command>")
	fmt.Println()
	fmt.Println("Available Commands:")
	fmt.Println("  help      Show help information")
	fmt.Println("  init      init Create an empty Gitter repository")
	fmt.Println("  add       add Add file contents to the index")
	fmt.Println("  commit    Commit staged changes")
	fmt.Println("  status    status Show the working tree status")
	fmt.Println("  log       Show commit history")
}
