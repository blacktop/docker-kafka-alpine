#!/bin/bash
set -e

if [ -z "$HOST_NAME" ]; then
	#use container's ip address if host name was specified
	HOST_NAME=$(hostname)
fi

if [ -z "$ADVERTISED_HOST_NAME" ]; then
	#use container's ip address if host name was specified
	ADVERTISED_HOST_NAME=$(hostname)
fi

BROKER_ID=${BROKER_ID:-0}
ZOOKEEPER_CONNECT=${ZOOKEEPER_CONNECT:-localhost:2181}
LOG_DIRS=${LOG_DIRS:-/tmp/kafka-logs}

sed 's/broker.id=0/broker.id='${BROKER_ID}'/' -i config/server.properties
sed 's/#advertised.host.name=<hostname routable by clients>/advertised.host.name='${ADVERTISED_HOST_NAME}'/' -i config/server.properties
sed 's/#host.name=localhost/'host.name=${HOST_NAME}'/' -i config/server.properties
sed 's/zookeeper.connect=localhost:2181/zookeeper.connect='${ZOOKEEPER_CONNECT}'/' -i config/server.properties
sed 's#log.dirs=/tmp/kafka-logs#log.dirs='${LOG_DIRS}'#' -i config/server.properties

exec "$@"
