#!/usr/bin/env bash

# check if server binary is already built
if [ ! -f ./bin/GrpcTodoServer ]; then
    # build server binary
    mkdir -p ./bin
    BIN_DIR=$(cd ./bin && pwd)
    cd ../grpc-apps/dotnet/GrpcTodo
    dotnet publish GrpcTodo.sln  --sc -c Release -o $BIN_DIR
fi