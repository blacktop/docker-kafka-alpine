![kafka-logo](https://raw.githubusercontent.com/blacktop/docker-kafka-alpine/master/kafka-logo.png)

docker-kafka-alpine
===================

[![License](http://img.shields.io/:license-mit-blue.svg)](http://doge.mit-license.org) [![Docker Stars](https://img.shields.io/docker/stars/blacktop/kafka.svg)](https://hub.docker.com/r/blacktop/kafka/) [![Docker Pulls](https://img.shields.io/docker/pulls/blacktop/kafka.svg)](https://hub.docker.com/r/blacktop/kafka/)

Alpine Linux based Kafka Docker Image

### Dependencies

-	[gliderlabs/alpine](https://index.docker.io/_/gliderlabs/alpine/)

### Image Tags

```bash
$ docker images

REPOSITORY                    TAG                 VIRTUAL SIZE
blacktop/kafka                latest              149   MB
```

### Usage

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
$ docker run -d --name kafka-1 -p 9092:9092 --link zookeeper blacktop/kafka
$ docker run -d --name kafka-2 -p 9093:9092 --link zookeeper blacktop/kafka
$ docker run -d --name kafka-3 -p 9094:9092 --link zookeeper blacktop/kafka
```

Or you can use [docker-compose](https://docs.docker.com/compose/) to make a single node cluster:

```bash
$ curl -sSL https://raw.githubusercontent.com/blacktop/docker-kafka-alpine/master/docker-compose.yml > docker-compose.yml && docker-compose up -d
```

### Issues

Find a bug? Want more features? Find something missing in the documentation? Let me know! Please don't hesitate to [file an issue](https://github.com/blacktop/docker-kafka-alpine/issues/new)

### Credits

### License

MIT Copyright (c) 2016 **blacktop**
