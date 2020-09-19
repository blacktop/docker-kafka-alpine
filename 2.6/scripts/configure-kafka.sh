#!/bin/bash

# set -eo pipefail

${KAFKA_BROKER_ID:=-1}
${KAFKA_PORT:=9092}

if [[ -z "$KAFKA_LOG_DIRS" ]]; then
    export KAFKA_LOG_DIRS="/kafka/kafka-logs/$HOSTNAME"
fi

if [[ -z "$KAFKA_ADVERTISED_PORT" ]]; then
    echo "DOCKER_KAFKA_PORT" "$(docker port `hostname` $KAFKA_PORT | sed -r "s/.*:(.*)/\1/g")"
    export KAFKA_ADVERTISED_PORT=$(docker port `hostname` $KAFKA_PORT | sed -r "s/.*:(.*)/\1/g")
    if [[ -z "$KAFKA_ADVERTISED_PORT" ]]; then
        export KAFKA_ADVERTISED_PORT=$KAFKA_PORT
    fi
fi
if [[ -z "$KAFKA_ADVERTISED_HOST_NAME" && -n "$HOSTNAME_COMMAND" ]]; then
    export KAFKA_ADVERTISED_HOST_NAME=$(eval $HOSTNAME_COMMAND)
fi
if [[ -z "$KAFKA_LISTENERS" ]]; then
    export KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:$KAFKA_PORT
    # unset KAFKA_PORT
fi
if [[ -z "$KAFKA_ADVERTISED_LISTENERS" ]]; then
    export KAFKA_ADVERTISED_LISTENERS="PLAINTEXT://$KAFKA_ADVERTISED_HOST_NAME:$KAFKA_ADVERTISED_PORT"
    unset KAFKA_ADVERTISED_HOST_NAME
    unset KAFKA_ADVERTISED_PORT
fi

if [[ -z "$KAFKA_ZOOKEEPER_CONNECT" ]]; then
    export KAFKA_ZOOKEEPER_CONNECT=$(env | grep ZOOKEEPER.*PORT_2181_TCP= | sed -e 's|.*tcp://||' | paste -sd ,)
    if [[ -z "$KAFKA_ZOOKEEPER_CONNECT" ]]; then
        # Start zookeeper locally.
    		echo "Configuring Zookeeper..."
    		/configure-zookeeper.sh
        zookeeper-server-start.sh config/zookeeper.properties &
        # wait for zookeeper to start
      	while ! nc -z localhost 2181
      	do
      	  echo "$(date) - still trying"
      	  sleep 1
      	done
      	echo "$(date) - connected successfully"
        export KAFKA_ZOOKEEPER_CONNECT="localhost:2181"
    fi
fi

# Set run env options
if [[ -n "$KAFKA_HEAP_OPTS" ]]; then
    sed -r -i "s/(export KAFKA_HEAP_OPTS)=\"(.*)\"/\1=\"$KAFKA_HEAP_OPTS\"/g" kafka-server-start.sh
    unset KAFKA_HEAP_OPTS
fi

for VAR in `env`
do
  if [[ $VAR =~ ^KAFKA_ && ! $VAR =~ ^KAFKA_HOME ]]; then
    kafka_name=`echo "$VAR" | sed -r "s/KAFKA_(.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr _ .`
    env_var=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g"`
    echo "DYNAMTIC CONFIG========================================================================="
    echo "$kafka_name=${!env_var}"
    if egrep -q "(^|^#)$kafka_name=" config/server.properties; then
        sed -r -i "s@(^|^#)($kafka_name)=(.*)@\2=${!env_var}@g" config/server.properties #note that no config values may contain an '@' char
    else
        echo "$kafka_name=${!env_var}" >> config/server.properties
    fi
  fi
done

# echo "Updated config/server.properties..."
# cat config/server.properties

# Make logs dirs
mkdir -p $KAFKA_LOG_DIRS
chown -R kafka:kafka $KAFKA_LOG_DIRS

if [[ -n "$KAFKA_CREATE_TOPICS" ]]; then
    su-exec kafka /create-topics.sh &
fi

# KAFKA_PID=0
#
# # see https://medium.com/@gchudnov/trapping-signals-in-docker-containers-7a57fdda7d86#.bh35ir4u5
# term_handler() {
#   echo 'Stopping Kafka....'
#   if [ $KAFKA_PID -ne 0 ]; then
#     kill -s TERM "$KAFKA_PID"
#     wait "$KAFKA_PID"
#   fi
#   echo 'Kafka stopped.'
#   exit
# }
#
#
# # Capture kill requests to stop properly
# trap "term_handler" SIGHUP SIGINT SIGTERM
# create-topics.sh &
# kafka-server-start.sh config/server.properties &
# KAFKA_PID=$!
#
# wait
