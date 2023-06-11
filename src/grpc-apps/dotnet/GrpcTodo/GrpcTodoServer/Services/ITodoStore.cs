namespace GrpcTodoServer.Services
{
    public interface ITodoStore
    {
        int AddTodoItem(string title, string description, bool isDone);
        void DeleteTodoItem(int id);
        (int id, string title, string description, bool isDone)[] GetTodoItems();
        void UpdateTodoItem(int id, string title, string description, bool isDone);
    }
}