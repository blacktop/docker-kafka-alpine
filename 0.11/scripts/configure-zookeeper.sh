#!/bin/bash

set -e

if [[ -z "$ZOOKEEPER_PORT" ]]; then
    export ZOOKEEPER_PORT=2181
fi

if [[ -z "$ZOOKEEPER_DATA" ]]; then
    export ZOOKEEPER_DATA=/tmp/zookeeper
fi
