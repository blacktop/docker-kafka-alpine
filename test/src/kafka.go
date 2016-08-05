package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"

	"github.com/docker/engine-api/client"
	"github.com/docker/engine-api/types"
	"github.com/optiopay/kafka"
	"github.com/optiopay/kafka/proto"
	"golang.org/x/net/context"
)

const (
	topic     = "test-topic"
	partition = 0
)

// printConsumed read messages from kafka and print them out
func printConsumed(broker kafka.Client) {
	conf := kafka.NewConsumerConf(topic, partition)
	conf.StartOffset = kafka.StartOffsetOldest
	consumer, err := broker.Consumer(conf)
	if err != nil {
		log.Fatalf("cannot create kafka consumer for %s:%d: %s", topic, partition, err)
	}

	for {
		msg, err := consumer.Consume()
		if err != nil {
			if err != kafka.ErrNoData {
				log.Printf("cannot consume %q topic message: %s", topic, err)
			}
			break
		}
		log.Printf("message %d: %s", msg.Offset, msg.Value)
	}
	log.Print("consumer quit")
}

// produceStdin read stdin and send every non empty line as message
func produceStdin(broker kafka.Client) {
	producer := broker.Producer(kafka.NewProducerConf())
	input := bufio.NewReader(os.Stdin)
	for {
		line, err := input.ReadString('\n')
		if err != nil {
			log.Fatalf("input error: %s", err)
		}
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}

		msg := &proto.Message{Value: []byte(line)}
		if _, err := producer.Produce(topic, partition, msg); err != nil {
			log.Fatalf("cannot produce message to %s:%d: %s", topic, partition, err)
		}
	}
}

func main() {
	var hostIP string

	if len(os.Args) > 0 {
		hostIP = os.Args[1]
	} else {
		log.Fatalln("Please supply Host IP.")
	}

	cli, err := client.NewEnvClient()

	options := types.ContainerListOptions{All: true}
	containers, err := cli.ContainerList(context.Background(), options)
	if err != nil {
		log.Fatal(err)
	}
	kafkaAddrs := []string{}

	for _, container := range containers {
		if strings.Contains(container.Names[0], "kafka") {
			ports := container.Ports
			kafkaAddrs = append(kafkaAddrs, hostIP+":"+strconv.Itoa(ports[0].PublicPort))
		}
	}

	fmt.Println("Kafka Hosts: ", kafkaAddrs)

	// connect to kafka cluster
	broker, err := kafka.Dial(kafkaAddrs, kafka.NewBrokerConf("go-client"))
	if err != nil {
		log.Fatalf("cannot connect to kafka cluster: %s", err)
	}
	defer broker.Close()

	go printConsumed(broker)
	produceStdin(broker)
}
