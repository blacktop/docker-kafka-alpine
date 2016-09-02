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

	if len(os.Args) > 1 {
		hostIP = os.Args[1]
	} else {
		log.Fatalln("[ERROR] Please supply Host IP.")
	}

	cli, err := client.NewEnvClient()
	if err != nil {
		log.Fatal(err)
	}
	// Check if client can connect
	if _, err = cli.Info(context.Background()); err != nil {
		// If failed to connect try to create docker client via socket
		defaultHeaders := map[string]string{"User-Agent": "engine-api-cli-1.0"}
		cli, err = client.NewClient("unix:///var/run/docker.sock", "v1.22", nil, defaultHeaders)
		if err != nil {
			log.Fatal(err)
		}
	}

	options := types.ContainerListOptions{All: true}
	containers, err := cli.ContainerList(context.Background(), options)
	if err != nil {
		log.Fatal(err)
	}

	kafkaAddrs := []string{}
	var kafkaPort string

	for _, container := range containers {
		ports := container.Ports
		for _, port := range ports {
			if port.PrivatePort == 9092 {
				kafkaPort = strconv.Itoa(port.PublicPort)
			}
		}
		fmt.Println("Container: ", container.Names[0])
		fmt.Println("Ports: ", ports)
		kafkaAddrs = append(kafkaAddrs, hostIP+":"+kafkaPort)
	}

	fmt.Println("Kafka Hosts: ", kafkaAddrs)

	// connect to kafka cluster
	broker, err := kafka.Dial(kafkaAddrs, kafka.NewBrokerConf("go-client"))
	if err != nil {
		log.Fatalf("cannot connect to kafka cluster: %s", err)
	}
	defer broker.Close()

	fmt.Print("Subscribed to topic: ", topic)
	fmt.Printf("\n\nType something and hit [enter]...\n\n")

	go printConsumed(broker)
	produceStdin(broker)
}
