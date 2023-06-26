#!/usr/bin/env bash

set -e

# Check envvar GRPC_TODO_SERVER is not empty 
if [ -z "$GRPC_TODO_SERVER" ]; then
    echo "GRPC_TODO_SERVER must be set to a valid URL."
    exit 1
fi

./build-bin.sh

python3 main.py
