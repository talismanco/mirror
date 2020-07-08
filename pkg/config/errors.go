package config

import "errors"

var (
	// ErrTemplateAlreadyExists indicates that a template is already present in the local registry.
	ErrTemplateAlreadyExists = errors.New("mirror: project template already exists")
)
