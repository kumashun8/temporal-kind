package main

import (
	"context"
	"fmt"
	"log"

	"go.temporal.io/sdk/client"

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

	options := client.StartWorkflowOptions{
		ID:        "hello-world-workflow",
		TaskQueue: "hello-world",
	}

	we, err := c.ExecuteWorkflow(context.Background(), options, app.Workflow, "Temporal")
	if err != nil {
		log.Fatalln("Unable to start workflow:", err)
	}

	log.Printf("Started workflow: WorkflowID=%s, RunID=%s\n", we.GetID(), we.GetRunID())

	var result string
	err = we.Get(context.Background(), &result)
	if err != nil {
		log.Fatalln("Unable to get workflow result:", err)
	}

	fmt.Printf("Workflow result: %s\n", result)
}
