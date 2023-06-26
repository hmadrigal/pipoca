#!/usr/bin/env bash

if [[ $EUID > 0 ]]; then
  echo "Please run as root/sudo"
  exit 1
fi

ip addr

cd ./bin/GrpcTodoServer/
ASPNETCORE_URLS=${ASPNETCORE_URLS:-"http://*:80"} ./GrpcTodoServer
