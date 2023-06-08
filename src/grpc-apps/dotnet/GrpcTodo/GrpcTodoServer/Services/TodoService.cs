using Grpc.Core;
using GrpcTodoServer.Services;
using Microsoft.Extensions.Logging;
using System.Linq;
using System.Threading.Tasks;

namespace GrpcTodoClient
{
    public class TodoService : Todo.TodoService.TodoServiceBase
    {
        private readonly ILogger _logger;
        private readonly TodoStore _todoStore;

        public TodoService(
            ILogger<TodoService> logger,
            TodoStore todoStore
        )
        {
            _logger = logger;
            _todoStore = todoStore;
        }

        public override Task<Todo.GetTodoItemsResponse> GetTodoItems(
            Todo.GetTodoItemsRequest request,
            ServerCallContext context
         )
        {
            var response = new Todo.GetTodoItemsResponse();

            response.Items.AddRange(_todoStore.GetTodoItems().Select(t => new Todo.TodoItem
            {
                Id = t.id,
                Title = t.title,
                Description = t.description,
                Completed = t.isDone
            }));

            return Task.FromResult(response);
        }

        // overrides CreateTodoItem method to add a new todo item to the database by accepting each parameter of the todo item and returning the id of the new item
        public override Task<Todo.CreateTodoItemResponse> CreateTodoItem(
            Todo.CreateTodoItemRequest request,
            ServerCallContext context
        )
        {
            var response = new Todo.CreateTodoItemResponse();
            var id = _todoStore.AddTodoItem(request.Title, request.Description, request.Completed);
            response.Item = new Todo.TodoItem { Id = id };
            return Task.FromResult(response);
        }

        // overrides UpdateTodoItem method to update an existing todo item in the database by accepting each parameter of the todo item and returning the id of the updated item
        public override Task<Todo.UpdateTodoItemResponse> UpdateTodoItem(
            Todo.UpdateTodoItemRequest request,
            ServerCallContext context
        )
        {
            var response = new Todo.UpdateTodoItemResponse();
            _todoStore.UpdateTodoItem(request.Id, request.Title, request.Description, request.Completed);
            response.Item = new Todo.TodoItem { Id = request.Id };
            return Task.FromResult(response);
        }

        // overrides DeleteTodoItem method to delete an existing todo item in the database by accepting the ID of the item to be deleted
        public override Task<Todo.DeleteTodoItemResponse> DeleteTodoItem(
            Todo.DeleteTodoItemRequest request,
            ServerCallContext context
        )
        {
            var response = new Todo.DeleteTodoItemResponse();
            _todoStore.DeleteTodoItem(request.Id);
            return Task.FromResult(response);
        }
    }
}
