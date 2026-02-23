package main

import (
	"log"

	"go.temporal.io/sdk/client"
	"go.temporal.io/sdk/worker"

	app "github.com/okuma/temporal-kind/temporal"
)

func main() {
	c, err := client.Dial(client.Options{
		HostPort: client.DefaultHostPort,
	})
	if err != nil {
		log.Fatalln("Unable to create Temporal client:", err)
	}
	defer c.Close()

	w := worker.New(c, "hello-world", worker.Options{})
	w.RegisterWorkflow(app.Workflow)
	w.RegisterActivity(app.Activity)

	err = w.Run(worker.InterruptCh())
	if err != nil {
		log.Fatalln("Unable to start Worker:", err)
	}
}
