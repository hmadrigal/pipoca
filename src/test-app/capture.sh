#!/usr/bin/env bash

set -e


if [[ $EUID > 0 ]]; then
  echo "Please run as root/sudo in order to capture packets."
  exit 1
fi

# Create output dir
mkdir -p ./traces

# Run tests
for i in $( find ./payloads/ -type f ); do 
  f=$( basename "${i}" .txt )
  
  echo "Running test ${f}."
  echo "Press enter to continue."
  read

  echo "Starting tcpdump. Press CTRL+C to stop."
  tcpdump -i ens33 -s 0 -w "./traces/${f}.pcap" port 80 
  echo "Test finished."
  
done

