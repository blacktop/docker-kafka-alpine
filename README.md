![kafka-logo](https://raw.githubusercontent.com/blacktop/docker-kafka-alpine/master/kafka-logo.png)

docker-kafka-alpine
===================

[![CircleCI](https://circleci.com/gh/blacktop/docker-kafka-alpine.png?style=shield)](https://circleci.com/gh/blacktop/docker-kafka-alpine) [![License](http://img.shields.io/:license-mit-blue.svg)](http://doge.mit-license.org) [![Docker Stars](https://img.shields.io/docker/stars/blacktop/kafka.svg)](https://hub.docker.com/r/blacktop/kafka/) [![Docker Pulls](https://img.shields.io/docker/pulls/blacktop/kafka.svg)](https://hub.docker.com/r/blacktop/kafka/) [![Docker Image](https://img.shields.io/badge/docker image-247.7 MB-blue.svg)](https://hub.docker.com/r/blacktop/kafka/)

Alpine Linux based [Kafka](http://kafka.apache.org/downloads.html) Docker Image

### Dependencies

-	[gliderlabs/alpine:3.4](https://index.docker.io/_/gliderlabs/alpine/)

### Image Tags

```bash
REPOSITORY          TAG                 SIZE
blacktop/kafka      latest              247.7 MB
blacktop/kafka      0.10                247.7 MB
blacktop/kafka      0.9                 238.6 MB
blacktop/kafka      0.8                 227.5 MB
```

### Getting Started

> **NOTE:** I am assuming use of docker-machine with these examples. (`KAFKA_ADVERTISED_HOST_NAME=192.168.99.100`\)

```
docker run -d \
           -p 9092:9092 \
           -e KAFKA_ADVERTISED_HOST_NAME=192.168.99.100 \
           -e KAFKA_CREATE_TOPICS="test-topic:1:1" \
           blacktop/kafka
```

This will create a single-node kafka broker (*listening on 192.168.99.100:9092*), a local zookeeper instance and create the topic `test-topic` with 1 `replication-factor` and 1 `partition`.

You can now test your new single-node kafka broker using the binaries in the `test` folder in this repo.

```bash
$ wget https://github.com/blacktop/docker-kafka-alpine/raw/master/test/darwin/kafka-test
$ chmod +x kafka-test
$ ./kafka-test `docker-machine ip`
```

```bash
Container:  /small_leavitt
Ports:  [{0.0.0.0 9092 9092 tcp} {0.0.0.0 2181 2181 tcp}]
Kafka Hosts:  [192.168.99.100:9092]
Subscribed to topic: test-topic

Type something and hit [enter]...

1
2016/08/05 13:02:14 message 0: 1
2
2016/08/05 13:02:15 message 1: 2
3
42016/08/05 13:02:15 message 2: 3
```

### Documentation

##### To start zookeeper

```bash
$ docker run -d -p 2181:2181 blacktop/kafka zookeeper-server-start.sh config/zookeeper.properties
```

##### To start kafka 3 node cluster

```bash
# Start zookeeper
$ docker run -d \
             -p 2181:2181 \
             --name zookeeper \
             blacktop/kafka zookeeper-server-start.sh config/zookeeper.properties
# Start 3 kafka nodes             
$ docker run -d \
             -v /var/run/docker.sock:/var/run/docker.sock \
             -e KAFKA_ADVERTISED_HOST_NAME=192.168.99.100 \
             --link zookeeper \
             -p 9092:9092 \
             --name kafka-1 \
             blacktop/kafka
$ docker run -d \
             -v /var/run/docker.sock:/var/run/docker.sock \
             -e KAFKA_ADVERTISED_HOST_NAME=192.168.99.100 \
             --link zookeeper \
             -p 9093:9092 \
             --name kafka-2 \
             blacktop/kafka
$ docker run -d \
             -v /var/run/docker.sock:/var/run/docker.sock \
             -e KAFKA_ADVERTISED_HOST_NAME=192.168.99.100 \
             --link zookeeper \
             -p 9094:9092 \
             --name kafka-3 \
             blacktop/kafka
# Create test-topic (replicated across kafka nodes)
$ docker run --rm \
             --link zookeeper \
             blacktop/kafka kafka-topics.sh --create --zookeeper zookeeper:2181 --replication-factor 3 --partition 1 --topic test-topic                           
```

Or you can use [docker-compose](https://docs.docker.com/compose/) to make a single node cluster:

```bash
$ curl -sL https://raw.githubusercontent.com/blacktop/docker-kafka-alpine/master/docker-compose.yml > docker-compose.yml
# Change KAFKA_ADVERTISED_HOST_NAME in docker-compose.yml to `docker-machine ip` or IP of your VM.
# OR supply a HOSTNAME_COMMAND function.
$ docker-compose up -d
$ docker-compose scale kafka=3
# Create test-topic (replicated across kafka nodes)
$ docker run --rm \
             --link zookeeper \
             blacktop/kafka kafka-topics.sh --create --zookeeper zookeeper:2181 --replication-factor 3 --partition 1 --topic test-topic  
```

#### Tips and Tricks

##### Get Kafka Host IPs

Linux

```bash
$ ifconfig docker0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'
```

Docker Machine

```bash
$ docker-machine ip <machine_name>
```

Docker for Mac

```bash
# It defaults to `localhost`
```

### Known Issues

For some reason I can't get the docker-compose example to work with Docker for Mac. It does, however, work great with docker-machine on OSX.

### Issues

Find a bug? Want more features? Find something missing in the documentation? Let me know! Please don't hesitate to [file an issue](https://github.com/blacktop/docker-kafka-alpine/issues/new)

### Credits

Heavily (if not entirely) influenced by https://github.com/wurstmeister/kafka-docker

### Todo

-	[x] Add ability to run a single node kafka broker when you don't supply a zookeeper link.

### CHANGELOG

See [`CHANGELOG.md`](https://github.com/blacktop/docker-kafka-alpine/blob/master/CHANGELOG.md)

### Contributing

[See all contributors on GitHub](https://github.com/blacktop/docker-kafka-alpine/graphs/contributors).

Please update the [CHANGELOG.md](https://github.com/blacktop/docker-kafka-alpine/blob/master/CHANGELOG.md) and submit a [Pull Request on GitHub](https://help.github.com/articles/using-pull-requests/).

### License

MIT Copyright (c) 2016 **blacktop**
