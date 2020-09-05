package main

import (
	"github.com/urfave/cli"
	"log"
	"os"
)

var AppVersion string

func main() {
	app := cli.NewApp()
	app.Name = "TBD"
	app.Usage = ""
	app.Version = AppVersion
	app.Commands = []cli.Command{
		{
			Name:        "foo",
			Description: "Foo",
			Action: func(c *cli.Context) error {
				log.Println("foooo")
				return nil
			},
		},
	}

	if err := app.Run(os.Args); err != nil {
		log.Fatalln(err)
	}

}
