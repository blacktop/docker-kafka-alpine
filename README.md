![kafka-logo](https://raw.githubusercontent.com/blacktop/docker-kafka-alpine/master/docs/kafka-logo.png)

# docker-kafka-alpine

[![CircleCI](https://circleci.com/gh/blacktop/docker-kafka-alpine.png?style=shield)](https://circleci.com/gh/blacktop/docker-kafka-alpine) [![License](http://img.shields.io/:license-mit-blue.svg)](http://doge.mit-license.org) [![Docker Stars](https://img.shields.io/docker/stars/blacktop/kafka.svg)](https://hub.docker.com/r/blacktop/kafka/) [![Docker Pulls](https://img.shields.io/docker/pulls/blacktop/kafka.svg)](https://hub.docker.com/r/blacktop/kafka/) [![Docker Image](https://img.shields.io/badge/docker%20image-437MB-blue.svg)](https://hub.docker.com/r/blacktop/kafka/)

Alpine Linux based [Kafka](http://kafka.apache.org/downloads.html) Docker Image

## Dependencies

* [alpine:3.10](https://hub.docker.com/_/alpine/)

## Image Tags

``` bash
REPOSITORY          TAG                 SIZE
blacktop/kafka      latest              437MB
blacktop/kafka      2.3                 437MB
blacktop/kafka      2.2                 411MB
blacktop/kafka      2.1                 300MB
blacktop/kafka      2.0                 300MB
blacktop/kafka      1.1                 332MB
blacktop/kafka      1.0                 234MB
blacktop/kafka      0.11                226MB
blacktop/kafka      0.10                437MB
blacktop/kafka      0.9                 238.6MB
blacktop/kafka      0.8                 227.5MB
```

## Getting Started

> **NOTE:** I am assuming use of Docker for Mac with these examples.( `KAFKA_ADVERTISED_HOST_NAME=localhost` )

``` 
docker run -d \
           --name kafka \
           -p 9092:9092 \
           -e KAFKA_ADVERTISED_HOST_NAME=localhost \
           -e KAFKA_CREATE_TOPICS="test-topic:1:1" \
           blacktop/kafka
```

This will create a single-node kafka broker (_listening on localhost:9092_), a local zookeeper instance and create the topic `test-topic` with 1 `replication-factor` and 1 `partition` .

You can now test your new single-node kafka broker using [Shopify/sarama's](https://github.com/Shopify/sarama) **kafka-console-producer** and **kafka-console-consumer**

### Required

* [Golang](https://golang.org/doc/install)

``` bash
$ go get github.com/Shopify/sarama/tools/kafka-console-consumer
$ go get github.com/Shopify/sarama/tools/kafka-console-producer
```

Now start a _consumer_ in the background and then send some data to **kafka** via a _producer_

``` bash
$ kafka-console-consumer --brokers=localhost:9092 --topic=test-topic &
$ echo "shrinky-dinks" | kafka-console-producer --brokers=localhost:9092 --topic=test-topic
```

## Documentation

* [Usage](https://github.com/blacktop/docker-kafka-alpine/blob/master/docs/usage.md)
* [Tips and Tricks](https://github.com/blacktop/docker-kafka-alpine/blob/master/docs/tips.md)

## Issues

Find a bug? Want more features? Find something missing in the documentation? Let me know! Please don't hesitate to [file an issue](https://github.com/blacktop/docker-kafka-alpine/issues/new)

## Credits

Heavily (if not entirely) influenced by <https://github.com/wurstmeister/kafka-docker>

## Todo

* [x] Add ability to run a single node kafka broker when you don't supply a zookeeper link.

## License

MIT Copyright (c) 2016-2019 **blacktop**

