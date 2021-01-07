package cmd

import (
	"encoding/json"
	"os"
	"path/filepath"

	"github.com/toyboxco/mirror/pkg/config"
	"github.com/toyboxco/mirror/pkg/template"
)

func serializeMetadata(tag string, repo string, targetDir string) error {
	fname := filepath.Join(targetDir, config.TemplateMetadataName)

	f, err := os.Create(fname)
	if err != nil {
		return err
	}
	defer f.Close()

	enc := json.NewEncoder(f)

	t := template.Metadata{tag, repo, template.NewTime()}
	if err := enc.Encode(&t); err != nil {
		return err
	}

	return nil
}
