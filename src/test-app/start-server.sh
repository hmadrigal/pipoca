#!/usr/bin/env bash

# Example run:
# sudo  ./start-server.sh

if [[ $EUID > 0 ]]; then
  echo "Please run as root/sudo"
  exit 1
fi

echo "Server Address: "
ip addr

echo ""


# Start tcpdump in the background
filename="GrpcTodoServer-$(date +%Y%m%d%H%M%S)"
pcap_file="${filename}.cap"
log_file="${filename}.log"
tcpdump -i ens33 -s 0 -w "./bin/GrpcTodoServer/${pcap_file}" port 80 &
TCPDUMP_PID=$!

# Start the server
echo "Starting GrpcTodoServer, see ${log_file} for details"
echo "Press Ctrl+C to stop the server"
echo "$(date) Starting GrpcTodoServer" >> "./bin/GrpcTodoServer/${log_file}"

cd ./bin/GrpcTodoServer/
ASPNETCORE_URLS=${ASPNETCORE_URLS:-"http://*:80"} ./GrpcTodoServer >> "${log_file}"

echo "$(date) GrpcTodoServer stopped" >> "${log_file}"

# Kill tcpdump
kill $TCPDUMP_PID