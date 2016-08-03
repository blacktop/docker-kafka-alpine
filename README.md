![kafka-logo](https://raw.githubusercontent.com/blacktop/docker-kafka-alpine/master/kafka-logo.png)

docker-kafka-alpine
===================

[![CircleCI](https://circleci.com/gh/blacktop/docker-kafka-alpine.png?style=shield)](https://circleci.com/gh/blacktop/docker-kafka-alpine)
[![License](http://img.shields.io/:license-mit-blue.svg)](http://doge.mit-license.org) [![Docker Stars](https://img.shields.io/docker/stars/blacktop/kafka.svg)](https://hub.docker.com/r/blacktop/kafka/) [![Docker Pulls](https://img.shields.io/docker/pulls/blacktop/kafka.svg)](https://hub.docker.com/r/blacktop/kafka/)
[![Docker Image](https://img.shields.io/badge/docker image-241.2 MB-blue.svg)](https://hub.docker.com/r/blacktop/kafka/)

Alpine Linux based [Kafka](http://kafka.apache.org/downloads.html) Docker Image

### Dependencies

-	[gliderlabs/alpine:3.4](https://index.docker.io/_/gliderlabs/alpine/)

### Image Tags

```bash
REPOSITORY          TAG                 SIZE
blacktop/kafka      latest              241.2 MB
blacktop/kafka      0.10                247.4 MB
blacktop/kafka      0.9                 241.2 MB
blacktop/kafka      0.8                 230.1 MB
```

### Getting Started

```
docker run -d -p 9092:9092 blacktop/kafka
```

### Documentation

##### To start zookeeper

```bash
$ docker run -d -p 2181:2181 blacktop/kafka zookeeper-server-start.sh config/zookeeper.properties
```

##### To start kafka 3 node cluster

```bash
$ docker run -d --name zookeeper -p 2181:2181 blacktop/kafka zookeeper-server-start.sh config/zookeeper.properties
$ docker run -d -v /var/run/docker.sock:/var/run/docker.sock \
                -e KAFKA_ADVERTISED_HOST_NAME=localhost \
                --link zookeeper \
                -p 9092:9092 \
                --name kafka-1 \
                blacktop/kafka
$ docker run -d -v /var/run/docker.sock:/var/run/docker.sock \
                -e KAFKA_ADVERTISED_HOST_NAME=localhost \
                --link zookeeper \
                -p 9093:9092 \
                --name kafka-2 \
                blacktop/kafka
$ docker run -d -v /var/run/docker.sock:/var/run/docker.sock \
                -e KAFKA_ADVERTISED_HOST_NAME=localhost \
                --link zookeeper \
                -p 9094:9092 \
                --name kafka-3 \
                blacktop/kafka                
```

Or you can use [docker-compose](https://docs.docker.com/compose/) to make a single node cluster:

```bash
$ curl -sL https://raw.githubusercontent.com/blacktop/docker-kafka-alpine/master/docker-compose.yml > docker-compose.yml && docker-compose up -d
$ docker-compose scale kafka=3
```

### Known Issues

#### test

### Issues

Find a bug? Want more features? Find something missing in the documentation? Let me know! Please don't hesitate to [file an issue](https://github.com/blacktop/docker-kafka-alpine/issues/new)

### Credits

Heavily (if not entirely) influenced by https://github.com/wurstmeister/kafka-docker

### CHANGELOG

See [`CHANGELOG.md`](https://github.com/blacktop/docker-kafka-alpine/blob/master/CHANGELOG.md)

### Contributing

[See all contributors on GitHub](https://github.com/blacktop/docker-kafka-alpine/graphs/contributors).

Please update the [CHANGELOG.md](https://github.com/blacktop/docker-kafka-alpine/blob/master/CHANGELOG.md) and submit a [Pull Request on GitHub](https://help.github.com/articles/using-pull-requests/).

### License

MIT Copyright (c) 2016 **blacktop**
