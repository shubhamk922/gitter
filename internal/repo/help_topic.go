package repo

import "fmt"

func HelpTopic(topic string) {
	switch topic {
	case "init":
		helpInit()
	case "add":
		helpAdd()
	case "commit":
		helpCommit()
	case "status":
		helpStatus()
	case "log":
		helpLog()
	default:
		fmt.Printf("No help topic for '%s'\n", topic)
	}
}
