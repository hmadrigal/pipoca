#!/usr/bin/env bash

set -e

# Check envvar GRPC_TODO_SERVER is not empty 
if [ -z "$GRPC_TODO_SERVER" ]; then
    echo "GRPC_TODO_SERVER must be set to a valid URL."
    exit 1
fi

if [[ $EUID > 0 ]]; then
  echo "Please run as root/sudo in order to capture packets."
  exit 1
fi

# Build the binary
./build-bin.sh

# Start tcpdump in the background
tcpdump -i ens33 -s 0 -w owap-positive-waf-matches.pcap port 80 &
TCPDUMP_PID=$!

# Wait for tcpdump to start
sleep 1

# Starts tests
python3 main.py

# Kill tcpdump
kill $TCPDUMP_PID


