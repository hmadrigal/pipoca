using Microsoft.Data.Sqlite;
using System;
using System.IO;

namespace GrpcTodoServer.Services
{
    public class TodoStore : ITodoStore
    {

        private static string databaseFilePath = Path.Combine(Environment.CurrentDirectory, "todo.db");

        private static SqliteConnection GetConnection()
        {
            var connectionStringBuilder = new SqliteConnectionStringBuilder();
            connectionStringBuilder.DataSource = databaseFilePath;
            var connection = new SqliteConnection(connectionStringBuilder.ConnectionString);
            connection.Open();
            return connection;
        }

        public static void Initialize()
        {
            if (File.Exists(databaseFilePath))
            {
                return;
            }
            using var connection = GetConnection();
            var createTableCmd = connection.CreateCommand();
            createTableCmd.CommandText = @"
                    CREATE TABLE IF NOT EXISTS TodoItems (
                        Id INTEGER PRIMARY KEY AUTOINCREMENT,
                        Title TEXT NOT NULL,
                        Description TEXT NOT NULL,
                        IsDone INTEGER NOT NULL
                    );
                ";
            createTableCmd.ExecuteNonQuery();
        }

        public TodoStore()
        {
            Initialize();
        }

        // adds a new todo item to the database by accepting each parameter of the todo item and returning the id of the new item
        public int AddTodoItem(string title, string description, bool isDone)
        {
            using var connection = GetConnection();
            var insertCmd = connection.CreateCommand();
            insertCmd.CommandText = @"
                    INSERT INTO TodoItems (Title, Description, IsDone)
                    VALUES ($title, $description, $isDone);
                    SELECT last_insert_rowid();
                ";
            insertCmd.Parameters.AddWithValue("$title", title);
            insertCmd.Parameters.AddWithValue("$description", description);
            insertCmd.Parameters.AddWithValue("$isDone", isDone);
            return Convert.ToInt32(insertCmd.ExecuteScalar());
        }

        // updates an existing todo item in the database by accepting each parameter of the todo item and the ID of the item to be updated
        public void UpdateTodoItem(int id, string title, string description, bool isDone)
        {
            using var connection = GetConnection();
            var updateCmd = connection.CreateCommand();
            updateCmd.CommandText = @"
                    UPDATE TodoItems
                    SET Title = $title, Description = $description, IsDone = $isDone
                    WHERE Id = $id;
                ";
            updateCmd.Parameters.AddWithValue("$id", id);
            updateCmd.Parameters.AddWithValue("$title", title);
            updateCmd.Parameters.AddWithValue("$description", description);
            updateCmd.Parameters.AddWithValue("$isDone", isDone);
            updateCmd.ExecuteNonQuery();
        }

        // deletes an existing todo item from the database by accepting the ID of the item to be deleted
        public void DeleteTodoItem(int id)
        {
            using var connection = GetConnection();
            var deleteCmd = connection.CreateCommand();
            deleteCmd.CommandText = @"
                    DELETE FROM TodoItems
                    WHERE Id = $id;
                ";
            deleteCmd.Parameters.AddWithValue("$id", id);
            deleteCmd.ExecuteNonQuery();
        }

        // returns all todo items from the database as an array of named tuples containing the ID, title, description, and isDone status of each item
        public (int id, string title, string description, bool isDone)[] GetTodoItems()
        {
            using var connection = GetConnection();
            var selectCmd = connection.CreateCommand();
            selectCmd.CommandText = @"
                    SELECT Id, Title, Description, IsDone
                    FROM TodoItems;
                ";
            using var reader = selectCmd.ExecuteReader();
            var todoItems = new System.Collections.Generic.List<(int id, string title, string description, bool isDone)>();
            while (reader.Read())
            {
                todoItems.Add((
                    reader.GetInt32(0),
                    reader.GetString(1),
                    reader.GetString(2),
                    reader.GetBoolean(3)
                    ));
            }
            return todoItems.ToArray();
        }

    }
}
