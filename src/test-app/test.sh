#!/usr/bin/env bash

set -e

WORK_DIR=$(cd $(dirname $0) && pwd)
mkdir -p ./bin
BIN_DIR=$(cd ./bin && pwd)
cd ../grpc-apps/dotnet/GrpcTodo
dotnet publish GrpcTodo.sln  --sc -c Release -o $BIN_DIR
cd $WORK_DIR
python3 main.py
