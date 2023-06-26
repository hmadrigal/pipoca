#!/usr/bin/env bash

if [[ $EUID > 0 ]]; then
  echo "Please run as root/sudo"
  exit 1
fi

export ASPNETCORE_URLS="http://*:80"
./bin/GrpcTodoServer/GrpcTodoServer