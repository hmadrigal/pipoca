# Summary

- `dotnet`
  - `GrpcGreeter` contains two applications. A server which exposes one gRPC service, with only one method that replies with a hello.

  - `GrpcTodo` A more complex application. A server which exposes one gRPC services with methods to perform CRUDs (Create, Reads, Update, and Delete) to handle TODO items.

The `dotnet` application can be compiled against .NET 7 and use `tcpdump` to capture traffic. Dockerfiles help you to capture networking traffic on each case. Traffic can also be capture by running apps and starting `tcpdump` instead of using the Docker.

