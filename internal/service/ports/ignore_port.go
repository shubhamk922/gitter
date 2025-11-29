package ports

type IgnorePatternLoader interface {
	LoadIgnorePatterns() []string
	ShouldIgnore(file string) bool
}
