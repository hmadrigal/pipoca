#region snippet2
using System;
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
            AppContext.SetSwitch( "System.Net.Http.SocketsHttpHandler.Http2UnencryptedSupport", true);

            // The port number(5001) must match the port of the gRPC server.
            using var channel = GrpcChannel.ForAddress("http://localhost:58634");
            var client = new Greeter.GreeterClient(channel);
            var cts = new CancellationTokenSource();
            _ = Task.Run(async () =>
            {
                while (true)
                {
                    var reply = await client.SayHelloAsync(
                                  new HelloRequest { Name = "GreeterClient" });
                    Console.WriteLine("Greeting: " + reply.Message);
                    await Task.Delay(1500);
                }
            }, cts.Token);

            Console.WriteLine("Press any key to exit...");
            while (Console.ReadKey().Key != ConsoleKey.Enter) { }
            cts.Cancel();
        }
        #endregion
    }
}
#endregion