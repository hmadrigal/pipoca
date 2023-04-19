#region snippet2
using System;
using System.Diagnostics;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using Grpc.Net.Client;

namespace GrpcGreeterClient
{
    class Program
    {
        #region snippet
        static async Task Main(string[] args)
        {
            await Task.Delay(1000);

            // Disables TLS, this switch must be set before creating the GrpcChannel/HttpClient.
            AppContext.SetSwitch("System.Net.Http.SocketsHttpHandler.Http2UnencryptedSupport", true);

            // The port number(5001) must match the port of the gRPC server.
            var grpcServerUrlText = Environment.GetEnvironmentVariable("GRPC_SERVER_URL") ?? "http://localhost:5001";
            Console.WriteLine($"gRPC Server URL: {grpcServerUrlText}");
            if (!Uri.TryCreate(grpcServerUrlText, UriKind.Absolute, out var grpcServerUri))
            {
                Console.WriteLine("Provide GRPC_SERVER_URL is not a valid Uri.");
            }
            using var channel = GrpcChannel.ForAddress(grpcServerUrlText);
            var client = new Greeter.GreeterClient(channel);
            var cts = new CancellationTokenSource();
            var messagingTask = Task.Run(async () =>
            {
                const int callMax = 10;
                var callCounter = 0;
                while (true && callCounter < callMax)
                {
                    var reply = await client.SayHelloAsync(
                                  new HelloRequest { Name = "GreeterClient" });
                    Console.WriteLine($"[{DateTime.Now:O}] Greeting: {reply.Message}");
                    await Task.Delay(1500);
                    callCounter++;
                }
            }, cts.Token);

            if (Debugger.IsAttached)
            {
                Console.WriteLine("Press any key to exit...");
                while (Console.ReadKey().Key != ConsoleKey.Enter) { }
                cts.Cancel();
            }
            else
            {
                await messagingTask;
            }
        }
        #endregion
    }
}
#endregion