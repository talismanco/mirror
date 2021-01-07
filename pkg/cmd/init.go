package cmd

import (
	"fmt"

	cli "github.com/spf13/cobra"
	"github.com/toyboxco/mirror/pkg/config"
	"github.com/toyboxco/mirror/pkg/util/exit"
	"github.com/toyboxco/mirror/pkg/util/osutil"
)

// Init contains the cli-command for initializing the local template
// registry in case it's not initialized.
var Init = &cli.Command{
	Use:   "init",
	Short: "Initialize directories required by mirror (By default done by installation script)",
	Run: func(c *cli.Command, _ []string) {
		// Check if .config/mirror exists
		if exists, err := osutil.DirExists(config.Configuration.TemplateDirPath); exists {
			if shouldRecreate := GetBoolFlag(c, "force"); !shouldRecreate {
				exit.GoodEnough("template registry is already initialized use -f to reinitialize")
			}
		} else if err != nil {
			exit.Error(fmt.Errorf("init: %s", err))
		}

		if err := osutil.CreateDirs(config.Configuration.TemplateDirPath); err != nil {
			exit.Error(err)
		}

		exit.OK("Initialization complete")
	},
}
