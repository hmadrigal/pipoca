#!/usr/bin/env bash

# Run example:
# sudo GRPC_TODO_SERVER=http://172.16.210.133 ./run-tests.sh

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

function exec_test_and_capture(){
    local payload_file=$1
    local capture_file=$2

    # Build the binary
    ./build-bin.sh

    # Start tcpdump in the background
    tcpdump -i ens33 -s 0 -w "${capture_file}" port 80 &
    TCPDUMP_PID=$!

    # Wait for tcpdump to start
    sleep 1

    # Starts tests
    export GRPC_TODO_PAYLOAD_FILE="${payload_file}"
    ./main.py
    unset GRPC_TODO_PAYLOAD_FILE

    # Kill tcpdump
    kill $TCPDUMP_PID
}

mkdir -p ./traces

exec_test_and_capture "./payloads/zeek-negative-matches.txt" "./traces/zeek-negative-matches.pcap"
exec_test_and_capture "./payloads/zeek-positive-matches.txt" "./traces/zeek-positive-matches.pcap"
exec_test_and_capture "./payloads/payloadbox-generic-sqli-positive.txt" "./traces/payloadbox-generic-sqli-positive.pcap"
exec_test_and_capture "./payloads/payloadbox-mysql-injection-bypass-positive.txt" "./traces/payloadbox-mysql-injection-bypass-positive.pcap"
exec_test_and_capture "./payloads/payloadbox-mysql-injection-local-files-positive.txt" "./traces/payloadbox-mysql-injection-local-files-positive.pcap"
exec_test_and_capture "./payloads/owap-positive-waf-matches.txt" "./traces/owap-positive-waf-matches.pcap"
