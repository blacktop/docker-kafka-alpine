#!/bin/bash

set -eo pipefail

if [[ -z "$ZOOKEEPER_PORT" ]]; then
    export ZOOKEEPER_PORT=2181
fi

if [[ -z "$ZOOKEEPER_DATA" ]]; then
    export ZOOKEEPER_DATA=/tmp/zookeeper
fi
