using System;
using System.CommandLine;
using System.CommandLine.Builder;
using System.CommandLine.Parsing;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using Grpc.Net.Client;

internal class Program
{
    //private const string variablePrefix = "GRPC_TODO_";
    //private const string variableServer = variablePrefix + "SERVER";
    // TODO: try to default to ENV VAR getDefaultValue: () => bool.Parse(Environment.GetEnvironmentVariable($"{variablePrefix}_TLS") ?? bool.FalseString)
    // TODO: try to default to ENV VAR getDefaultValue: () => Environment.GetEnvironmentVariable(variableServer)

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

        // create batch command options
        var createBatchFilePathOption = new Option<string>("--filepath", "File path with titles") { IsRequired = true };
        var createBatchTitleFormat = new Option<string>("--format", () => "{0}", "Description of the new TODO entry.") { IsRequired = false };
        var createBatchCommand = new Command("create-batch", "Creates a batch of TODO items.")
        { createBatchFilePathOption, createBatchTitleFormat };

        createBatchCommand.SetHandler(CreateBatchCommandHandler, tlsOption, serverOption, createBatchFilePathOption, createBatchTitleFormat);

        // read command options

        var readIdOption = new Option<int?>("--id", "Id of the TODO target.") { IsRequired = false };
        var readCommand = new Command("read", "Get TODO items from the store.") { readIdOption };
        readCommand.SetHandler(ReadCommandHandler, tlsOption, serverOption, readIdOption);

        // update command options
        var updateIdOption = new Option<int>("--id", "Id of the TODO target.") { IsRequired = true };
        var updateTitleOption = new Option<string>("--title", "New title of the existing TODO entry.") { IsRequired = true };
        var updateDescriptionOption = new Option<string>("--description", () => string.Empty, "New description of the existing TODO entry.") { IsRequired = false };
        var updateCompletedOption = new Option<bool?>("--completed", () => default, "New complete status of the existing TODO entry.") { IsRequired = false };
        var updateCommand = new Command("update", "Modifies an existing TODO item.") { updateIdOption, updateTitleOption, updateDescriptionOption, updateCompletedOption };

        updateCommand.SetHandler(UpdateCommandHandler, tlsOption, serverOption, updateIdOption, updateTitleOption, updateDescriptionOption, updateCompletedOption);

        // delete command options
        var deleteIdOption = new Option<int>("--id", "Id of the TODO target.") { IsRequired = true };
        var deleteCommand = new Command("delete", "Removes an existing TODO item.") { deleteIdOption };
        deleteCommand.SetHandler(DeleteCommandHandler, tlsOption, serverOption, deleteIdOption);

        // root command
        var rootCommand = new RootCommand() {
            createCommand, createBatchCommand, readCommand, updateCommand, deleteCommand
        };
        rootCommand.AddGlobalOption(tlsOption);
        rootCommand.AddGlobalOption(serverOption);

        var parser = new CommandLineBuilder(rootCommand)
            .UseDefaults()
            .Build();
        ;
        Environment.ExitCode = await parser.InvokeAsync(args);
    }

    private static void UpdateCommandHandler(bool tls, string server, int id, string title, string description, bool? completed)
    {
        var (client, _) = GetNewClient(tls, server);
        var cts = new CancellationTokenSource();
        var updateTodoItemResponse = client.UpdateTodoItem(new Todo.UpdateTodoItemRequest
        {
            Id = id,
            Title = title,
            Description = description,
            Completed = completed ?? false
        }, cancellationToken: cts.Token);

        Console.Out.WriteLine($"Updated TODO item with id {updateTodoItemResponse.Item.Id}.");
    }

    private static void DeleteCommandHandler(bool tls, string server, int id)
    {
        var (client, _) = GetNewClient(tls, server);
        var cts = new CancellationTokenSource();
        _ = client.DeleteTodoItem(new Todo.DeleteTodoItemRequest
        {
            Id = id
        }, cancellationToken: cts.Token);

        Console.Out.WriteLine($"Deleted TODO item with id {id}.");
    }

    private static async Task ReadCommandHandler(bool tls, string server, int? id)
    {
        var (client, _) = GetNewClient(tls, server);
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


    }

    private static async Task CreateBatchCommandHandler(bool tls, string server, string filepath, string format)
    {
        Console.Out.WriteLine($"tls: {tls}");
        Console.Out.WriteLine($"server: {server}");
        Console.Out.WriteLine($"filepath: {filepath}");
        Console.Out.WriteLine($"format: {format}");

        var counterNewTodoItems = 0;
        var (client, _) = GetNewClient(tls, server);
        var cts = new CancellationTokenSource();
        var lines = File.ReadLines(filepath);
        int counter = 0;

        foreach(var line in lines)
        {

            if (string.IsNullOrWhiteSpace(line))
            { continue; }
            var formatted_line = line.TrimEnd('\n');
            formatted_line = string.Format(format,formatted_line);

            var createTodoItemResponse = await client.CreateTodoItemAsync(new Todo.CreateTodoItemRequest
            {
                Title = formatted_line,
                Description = $"Description {++counter} ",
                Completed = false
            }, cancellationToken: cts.Token);

            counterNewTodoItems++;
            Console.Out.WriteLine($"Created TODO item with id {createTodoItemResponse.Item.Id}.");

        }

        Console.Out.WriteLine($"Created {counterNewTodoItems} TODO items.");

    }

    private static async Task CreateCommandHandler(bool tls, string server, string title, string description, bool completed)
    {
        Console.Out.WriteLine($"tls: {tls}");
        Console.Out.WriteLine($"server: {server}");
        Console.Out.WriteLine($"title: {title}");
        Console.Out.WriteLine($"description: {description}");
        Console.Out.WriteLine($"completed: {completed}");


        var (client, _) = GetNewClient(tls, server);
        var cts = new CancellationTokenSource();
        var createTodoItemResponse = await client.CreateTodoItemAsync(new Todo.CreateTodoItemRequest
        {
            Title = title,
            Description = description,
            Completed = completed
        }, cancellationToken: cts.Token);

        Console.Out.WriteLine($"Created TODO item with id {createTodoItemResponse.Item.Id}.");

    }

    private static (Todo.TodoService.TodoServiceClient client, GrpcChannel channel) GetNewClient(bool tls, string server)
    {
        GrpcChannel channel;
        Todo.TodoService.TodoServiceClient client;
        if (tls)
        {
            Console.Out.WriteLine("TLS is enabled.");
            AppContext.SetSwitch("System.Net.Http.SocketsHttpHandler.Http2UnencryptedSupport", true);
        }
        channel = GrpcChannel.ForAddress(server);
        client = new Todo.TodoService.TodoServiceClient(channel);
        return (client, channel);
    }
}