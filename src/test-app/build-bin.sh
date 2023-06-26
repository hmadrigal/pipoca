#!/usr/bin/env bash


set -ex

# check if server binary is already built
if [ ! -f ./bin/GrpcTodoServer/GrpcTodoServer ]; then
    # build server binary
    mkdir -p ./bin/GrpcTodoServer
    BIN_DIR=$(cd ./bin/GrpcTodoServer && pwd)
    cd ../grpc-apps/dotnet/GrpcTodo/GrpcTodoServer
    dotnet publish --sc -c Release -o $BIN_DIR
    cd $OLDPWD
fi

# check if client binary is already built
if [ ! -f ./bin/GrpcTodoClient/GrpcTodoClient ]; then
    # build client binary
    mkdir -p ./bin/GrpcTodoClient
    BIN_DIR=$(cd ./bin/GrpcTodoClient && pwd)
    cd ../grpc-apps/dotnet/GrpcTodo/GrpcTodoClient
    dotnet publish --sc -c Release -o $BIN_DIR
    cd $OLDPWD
fi