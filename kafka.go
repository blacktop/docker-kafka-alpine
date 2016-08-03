package main

import (
	"bufio"
	"log"
	"os"
	"strings"

	"github.com/optiopay/kafka"
	"github.com/optiopay/kafka/proto"
)

const (
	topic     = "my-replicated-topic"
	partition = 0
)

var kafkaAddrs = []string{"localhost:9092", "localhost:9093", "localhost:9094"}

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
	// connect to kafka cluster
	broker, err := kafka.Dial(kafkaAddrs, kafka.NewBrokerConf("go-client"))
	if err != nil {
		log.Fatalf("cannot connect to kafka cluster: %s", err)
	}
	defer broker.Close()

	go printConsumed(broker)
	produceStdin(broker)
}
