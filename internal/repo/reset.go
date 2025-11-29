package repo

import (
	"fmt"
	"gitter/internal/service"
)

func ResetHead(args []string, svc *service.ResetHeadUseCase) {
	if !ensureRepo() {
		fmt.Println("Not a gitter repo")
		return
	}
	svc.Execute(args)

}
