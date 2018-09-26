package softwareupgrade

type (
	// HashInterface defines the interface that must be implemented
	HashInterface interface {
		Hash(filename string) (string, error)
	}
)
