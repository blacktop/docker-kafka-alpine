#!/bin/bash
#author		 :https://github.com/wurstmeister/kafka-docker
#license	 :https://raw.githubusercontent.com/wurstmeister/kafka-docker/master/LICENSE

if [[ -z "$START_TIMEOUT" ]]; then
    START_TIMEOUT=600
fi

${KAFKA_PORT:=9092}

start_timeout_exceeded=false
count=0
step=5

echo "===> looking for $KAFKA_PORT"
netstat -lnt

while netstat -lnt | awk '$4 ~ /:'$KAFKA_PORT'$/ {exit 1}'; do
    echo "waiting for kafka to be ready"
    sleep $step;
    count=$(expr $count + $step)
    if [ $count -gt $START_TIMEOUT ]; then
        start_timeout_exceeded=true
        break
    fi
done

if $start_timeout_exceeded; then
    echo "Not able to auto-create topic (waited for $START_TIMEOUT sec)"
    exit 1
fi

if [[ -n $KAFKA_CREATE_TOPICS ]]; then
    IFS=','; for topicToCreate in $KAFKA_CREATE_TOPICS; do
        echo "creating topics: $topicToCreate"
        IFS=':' read -a topicConfig <<< "$topicToCreate"
        JMX_PORT='' kafka-topics.sh --bootstrap-server $KAFKA_ZOOKEEPER_CONNECT --create --replication-factor ${topicConfig[2]} --partitions ${topicConfig[1]} --topic "${topicConfig[0]}"
    done
fi
