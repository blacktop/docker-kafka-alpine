#!/bin/bash

set -e
if [ "$1" = "" ];then
	echo availabale script:
	echo "  zookeeper-server-start.sh"
	echo "  kafka-server-start.sh"
	echo "  kafka-topics.sh"
	echo "  kafka-console-producer.sh"
	echo "  kafka-console-consumer.sh"
	echo "  kafka-run-class.sh"
fi

if [[ "$1" == *kafka* || "$1" == *zookeeper* ]]; then
	if [[ "$1" == *kafka-server-start.sh && "$2" == *server.properties ]];then
		mkdir -p /tmp/kafka-logs
		chown -R kafka:kafka /tmp/kafka-logs
		if [ "$KAFKA_ADVERTISED_HOST_NAME" ];then
			sed -ri "/#advertised.host.name=*/a\advertised.host.name=$KAFKA_ADVERTISED_HOST_NAME" $2
		else
			echo >&2 'warning:missing KAFKA_ADVERTISED_HOST_NAME'
			echo >&2 'Did you forget -e KAFKA_ADVERTISED_HOST_NAME=some-hostname?'
		fi
		if [ "$KAFKA_ADVERTISED_PORT" ];then
			sed -ri "/#advertised.port=*/a\advertised.port=$KAFKA_ADVERTISED_PORT" $2
		fi
		if [ "$ZOOKEEPER_CONNECT" -o "$ZOOKEEPER_PORT_2181_TCP_ADDR" ];then
			: ${ZOOKEEPER_CONNECT:=$ZOOKEEPER_PORT_2181_TCP_ADDR:$ZOOKEEPER_PORT_2181_TCP_PORT}
			sed -ri "s!^(zookeeper.connect=).*!\1 $ZOOKEEPER_CONNECT!" $2
		else
			echo >&2 'warning:missing ZOOKEEPER_PORT_2181_TCP_ADDR or ZOOKEEPER_CONNECT'
			echo >&2 'Did you forget to --link some-zookeeper:zookeeper'
			echo >&2 'or -e ZOOKEEPER_CONNECT=ip:port?'
		fi

		if [ "$KAFKA_BROKER_ID" ];then
			sed -ri "s!^(broker.id=).*!\1 $KAFKA_BROKER_ID!" $2
		fi
	fi
	set -- gosu kafka tini -- "$@"
fi

exec "$@"
