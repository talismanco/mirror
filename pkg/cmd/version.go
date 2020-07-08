package cmd

import (
	"fmt"

	cli "github.com/spf13/cobra"

	"github.com/lunaris-studios/mirror/pkg/config"
	"github.com/lunaris-studios/mirror/pkg/util/tlog"
	"github.com/lunaris-studios/mirror/pkg/util/validate"
)

// Version contains the cli-command for printing the current version of the tool.
var Version = &cli.Command{
	Use:   "version",
	Short: "Show the mirror version information",
	Run: func(c *cli.Command, args []string) {
		MustValidateArgs(args, []validate.Argument{})

		shouldntPrettify := GetBoolFlag(c, "dont-prettify")
		if shouldntPrettify {
			fmt.Println(config.Version)
		} else {
			tlog.Info(fmt.Sprint("Current version is ", config.Version))
		}
	},
}
