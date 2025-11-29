package cli

import (
	"os"
)

func ensureRepo() bool {
	_, err := os.Stat(".gitter")
	return err == nil
}
