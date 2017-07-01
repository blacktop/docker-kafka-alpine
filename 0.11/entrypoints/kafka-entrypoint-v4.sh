#!/bin/bash

set -e
if [ "$1" = "" ];then
	echo availabale scripts:
	echo "  zookeeper-server-start.sh"
	echo "  kafka-server-start.sh"
	echo "  kafka-topics.sh"
	echo "  kafka-console-producer.sh"
	echo "  kafka-console-consumer.sh"
	echo "  kafka-run-class.sh"
fi

if [[ "$1" == *kafka* || "$1" == *zookeeper* ]]; then
	if [[ "$1" == *kafka-server-start.sh && "$2" == *server.properties ]];then
		chown -R kafka:kafka /opt/kafka

		echo "===> Configuring Kafka..."
		/configure-kafka.sh
	fi
	if [[ "$1" == *zookeeper-server-start.sh && "$2" == *zookeeper.properties ]];then
		chown -R kafka:kafka /opt/kafka

		echo "===> Configuring Zookeeper..."
		/configure-zookeeper.sh
	fi

	chown -R kafka:kafka /opt/kafka
	# if [[ "$1" == *kafka-topics.sh ]];then
	# 	chown -R kafka:kafka /opt/kafka
	#
	# 	echo "Configuring Kafka..."
	# 	/configure-kafka.sh
	# fi
	set -- su-exec kafka tini -- "$@"
fi

exec "$@"
