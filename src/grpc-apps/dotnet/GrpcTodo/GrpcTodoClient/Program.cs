using System;
using System.CommandLine;
using System.CommandLine.Builder;
using System.CommandLine.Invocation;
using System.CommandLine.Parsing;
using System.Net.Http.Headers;
using System.Threading;
using System.Threading.Tasks;
using Grpc.Net.Client;
using Microsoft.Extensions.Logging;

internal class Program
{
    //private const string variablePrefix = "GRPC_TODO_";
    //private const string variableServer = variablePrefix + "SERVER";
    // TODO: try to default to ENV VAR getDefaultValue: () => bool.Parse(Environment.GetEnvironmentVariable($"{variablePrefix}_TLS") ?? bool.FalseString)
    // TODO: try to default to ENV VAR getDefaultValue: () => Environment.GetEnvironmentVariable(variableServer)
    //private static Func<Todo.TodoService.TodoServiceClient> _todoServiceClientFactory;

    private static async Task Main(string[] args)
    {
        // root command options
        var tlsOption = new Option<bool>("--tls", "Use TLS to connect to the gRPC server.") { IsRequired = false };
        var serverOption = new Option<string>("--server", description: "gRPC server URL.") { IsRequired = true };

        // create command options
        var createTitleOption = new Option<string>("--title", "Title of the new TODO entry.") { IsRequired = true };
        var createDescriptionOption = new Option<string>("--description", () => string.Empty, "Description of the new TODO entry.") { IsRequired = false };
        var createCompletedOption = new Option<bool>("--completed", () => false, "Complete status of the new TODO entry.") { IsRequired = false };
        var createCommand = new Command("create", "Adds a new TODO item.")
        { createTitleOption, createDescriptionOption, createCompletedOption };

        createCommand.SetHandler(CreateCommandHandler, tlsOption, serverOption, createTitleOption, createDescriptionOption, createCompletedOption);

        // read command options

        var readIdOption = new Option<int?>("--id", "Id of the TODO target.") { IsRequired = false };
        var readCommand = new Command("read", "Get TODO items from the store.") { readIdOption };
        readCommand.SetHandler(async (int? id) =>
        {
            if (id.HasValue)
            {
                Console.Out.WriteLine($"id: {id}");
            }
            var client = _todoServiceClientFactory();
            var cts = new CancellationTokenSource();
            var readTodoItemResponse = await client.GetTodoItemsAsync(new Todo.GetTodoItemsRequest
            {
            }, cancellationToken: cts.Token);

            foreach (var item in readTodoItemResponse.Items)
            {
                Console.Out.WriteLine($"Read TODO item with id {item.Id}.");
                Console.Out.WriteLine($"Title: {item.Title}");
                Console.Out.WriteLine($"Description: {item.Description}");
                Console.Out.WriteLine($"Completed: {item.Completed}");
            }

            Console.Out.WriteLine($"Read {readTodoItemResponse.Items.Count} TODO items.");


        }, readIdOption);

        // update command options
        var updateIdOption = new Option<int>("--id", "Id of the TODO target.") { IsRequired = true };
        var updateTitleOption = new Option<string>("--title", "New title of the existing TODO entry.") { IsRequired = true };
        var updateDescriptionOption = new Option<string>("--description", () => string.Empty, "New description of the existing TODO entry.") { IsRequired = false };
        var updateCompletedOption = new Option<bool?>("--completed", () => default, "New complete status of the existing TODO entry.") { IsRequired = false };
        var updateCommand = new Command("update", "Modifies an existing TODO item.") { updateIdOption, updateTitleOption, updateDescriptionOption, updateCompletedOption };

        // delete command options
        var deleteIdOption = new Option<int>("--id", "Id of the TODO target.") { IsRequired = true };
        var deleteCommand = new Command("delete", "Removes an existing TODO item.") { deleteIdOption };

        // root command
        var rootCommand = new RootCommand() {
            createCommand, readCommand, updateCommand, deleteCommand
        };
        rootCommand.AddGlobalOption(tlsOption);
        rootCommand.AddGlobalOption(serverOption);

        //rootCommand.SetHandler(RootCommandHandler, tlsOption, serverOption);

        var parser = new CommandLineBuilder(rootCommand)
            .UseDefaults()
            .Build();
        ;
        Environment.ExitCode = await parser.InvokeAsync(args);
    }

    //private static void RootCommandHandler(bool tls, string server)
    //{
    //    Console.Out.WriteLine($"tls: {tls}");

    //    Console.Out.WriteLine($"server: {server}");

    //    AppContext.SetSwitch("System.Net.Http.SocketsHttpHandler.Http2UnencryptedSupport", tls);
    //    Console.Out.WriteLine($"TLS is {(tls ? "enabled" : "disabled")}.");

    //    _todoServiceClientFactory = () =>
    //    {
    //        using var channel = GrpcChannel.ForAddress(server);
    //        var client = new Todo.TodoService.TodoServiceClient(channel);
    //        return client;
    //    };

    //}

    private static async Task CreateCommandHandler(bool tls, string server, string title, string description, bool completed)
    {
        Console.Out.WriteLine($"tls: {tls}");
        Console.Out.WriteLine($"server: {server}");
        Console.Out.WriteLine($"title: {title}");
        Console.Out.WriteLine($"description: {description}");
        Console.Out.WriteLine($"completed: {completed}");

        if (tls)
        {
            Console.Out.WriteLine("TLS is enabled.");
            AppContext.SetSwitch("System.Net.Http.SocketsHttpHandler.Http2UnencryptedSupport", true);
        }

        using var channel = GrpcChannel.ForAddress(server);
        var client = new Todo.TodoService.TodoServiceClient(channel);
        var cts = new CancellationTokenSource();
        var createTodoItemResponse = await client.CreateTodoItemAsync(new Todo.CreateTodoItemRequest
        {
            Title = title,
            Description = description,
            Completed = completed
        }, cancellationToken: cts.Token);

        Console.Out.WriteLine($"Created TODO item with id {createTodoItemResponse.Item.Id}.");

    }
}

//// Disables TLS, this switch must be set before creating the GrpcChannel/HttpClient.
//AppContext.SetSwitch("System.Net.Http.SocketsHttpHandler.Http2UnencryptedSupport", true);

//// The port number(5001) must match the port of the gRPC server.
//var grpcServerUrlText = Environment.GetEnvironmentVariable("GRPC_SERVER_URL") ??
//    (RuntimeInformation.IsOSPlatform(OSPlatform.OSX) ? "http://localhost:58634" : "http://localhost:5001");
//Console.WriteLine($"gRPC Server URL: {grpcServerUrlText}");
//if (!Uri.TryCreate(grpcServerUrlText, UriKind.Absolute, out var grpcServerUri))
//{
//    Console.WriteLine("Provide GRPC_SERVER_URL is not a valid Uri.");
//}
//using var channel = GrpcChannel.ForAddress(grpcServerUrlText);
//var client = new Todo.TodoService.TodoServiceClient(channel);
//var cts = new CancellationTokenSource();
//var messagingTask = Task.Run(async () =>
//{
//    //const int callMax = 10;
//    //var callCounter = 0;
//    //while (true && callCounter < callMax)
//    //{
//    //    var reply = await client.SayHelloAsync(
//    //                  new HelloRequest { Name = "GreeterClient" });
//    //    Console.WriteLine($"[{DateTime.Now:O}] Greeting: {reply.Message}");
//    //    await Task.Delay(1500);
//    //    callCounter++;
//    //}
//    await Task.Yield();
//    // TODO: call the service
//}, cts.Token);

//if (Debugger.IsAttached)
//{
//    Console.WriteLine("Press any key to exit...");
//    while (Console.ReadKey().Key != ConsoleKey.Enter) { }
//    cts.Cancel();
//}
//else
//{
//    await messagingTask;
//}