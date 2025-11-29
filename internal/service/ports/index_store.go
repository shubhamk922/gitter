package ports

import "gitter/internal/domain"

type IndexStore interface {
	Load() (domain.Index, error)
	Save(index domain.Index) error
}
