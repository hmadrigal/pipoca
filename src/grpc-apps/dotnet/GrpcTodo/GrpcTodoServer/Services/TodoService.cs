using Microsoft.Extensions.Logging;

namespace GrpcTodoClient
{
    public class TodoService : Todo.TodoService.TodoServiceBase
    {
        private readonly ILogger<TodoService> _logger;
        public TodoService(ILogger<TodoService> logger)
        {
            _logger = logger;
        }

    }
}
