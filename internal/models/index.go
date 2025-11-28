package models

type Index struct {
	Staged   []string `json:"staged"`
	Modified []string `json:"modified"`
}
