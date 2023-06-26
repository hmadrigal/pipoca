#!/usr/bin/env bash


set -ex

CURRENT_DIR=${PWD}
mkdir -p ./bin
# check if server binary is already built
if [ ! -f ./bin/GrpcTodoServer/GrpcTodoServer ]; then
    cd ../grpc-apps/dotnet/GrpcTodo/GrpcTodoServer
    rm -rf ./bin/Release/net7.0/linux-x64/publish
    dotnet publish --sc -c Release
    mv ./bin/Release/net7.0/linux-x64/publish ${CURRENT_DIR}/bin/GrpcTodoServer
    cd ${CURRENT_DIR}
fi

# check if client binary is already built
if [ ! -f ./bin/GrpcTodoClient/GrpcTodoClient ]; then
    cd ../grpc-apps/dotnet/GrpcTodo/GrpcTodoClient
    rm -rf ./bin/Release/net7.0/linux-x64/publish
    dotnet publish --sc -c Release
    mv ./bin/Release/net7.0/linux-x64/publish ${CURRENT_DIR}/bin/GrpcTodoClient
    cd ${CURRENT_DIR}
fi