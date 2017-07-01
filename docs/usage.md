Usage
-----

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
