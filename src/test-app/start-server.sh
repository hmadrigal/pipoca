#!/usr/bin/env bash

if [[ $EUID > 0 ]]; then
  echo "Please run as root/sudo"
  exit 1
fi

ip addr

export ASPNETCORE_URLS="http://*:80"
./bin/GrpcTodoServer/GrpcTodoServer
