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

    # # Start tcpdump in the background
    # tcpdump -i ens33 -s 0 -w "${capture_file}" port 80 &
    # TCPDUMP_PID=$!

    # Wait for tcpdump to start
    # sleep 1

    echo "Running test with payload ${payload_file}"
    echo "Press enter to continue."
    read

    # Starts tests
    export GRPC_TODO_PAYLOAD_FILE="${payload_file}"
    ./main.py
    unset GRPC_TODO_PAYLOAD_FILE

    echo "Test finished."
    # # Kill tcpdump
    # kill $TCPDUMP_PID
}


# Build the binary
./build-bin.sh

# Create output dir
mkdir -p ./traces

# Run tests
for i in $( find ./payloads/ -type f ); do 
  f=$( basename "${i}" .txt )
  echo "Running test ${f}"
  time exec_test_and_capture "./payloads/${f}.txt" "./traces/${f}.pcap"
done

sleep 1
