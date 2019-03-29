#!/bin/bash

set -euo pipefail

TOPIC_LIST=$(echo $TOPIC_LIST | tr -d '"')

pidof java
if [[ $? -ne 0 ]]; then
    echo "ERROR - JRE not found"
    exit 1
fi

echo "Checking topic list..."
list=$(bin/kafka-topics.sh --zookeeper $ZOOKEEPER_CONNECT --list)

echo "INFO - Checking topic list: $list"
for topic in $TOPIC_LIST
do
    if [[ $list =~ ^.*$topic ]]; then
        echo "INFO - Topic $topic exists"
    else
        echo "ERROR - Topic $topic does not exist"
        exit 1
    fi
done
