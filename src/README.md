# Summary

This repository initially was meant to create a Zeek plug-in for analyzing gRPC.
Initial tests using `Spicy`, trying out `init-plugin` command, and last checking `zkg` for creating a Zeek plug-in.

The directory `deprecated` contains the code related to the proof of concept.
The directory `grpc-apps` contains applications that uses gRPC, meant to be used for testing.
The directory  `test-app` contains apps which use gRPC apps in order to send positive-positive and positive-negative tests.

## Test Apps

The directory `test-app` contains a directory `payloads`, this directory contains different payload that are considered SQLi injection attacks. The subdirectory `bin` is used to store the server and client  applications which communicate using gRPC. The gRPCa applications are taken from `grpc-apps/dotnet/GrpcTodo`.

This, there are two main scripts which starts a given application and capture the traffic.

- `start-server.sh` It starts the gRPC server application, and capture the traffic automatically.
- `run-tests.sh`. It uses the gRPC client application to perform requests. Each request performs a 'create' call with a payload from `payload` directory. The `payload` directory withholds samples of SQLi from [sql-injection-payload-list]([https://](https://github.com/payloadbox/sql-injection-payload-list/tree/master)).