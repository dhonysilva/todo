defmodule TodoServer do
  def start do
    spawn(fn -> loop(TodoList.new()) end)
  end

  defp loop(todo_list) do
    new_todo_list =
      receive do
        message -> process_message(todo_list, message)
      end

    loop(new_todo_list)
  end

  def add_entry(todo_server, new_entry) do
    send(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    send(todo_server, {:entries, self(), date})

    receive do
      {:todo_entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end

  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end
end

defmodule TodoList do
  # Struct that describes the To-do list
  defstruct next_id: 1, entries: %{}

  # Interativelly create a new TodoList itens from a raw list of Entry instances
  # into an instance of the struct %TodoList struct relying on the Enum.reduce/3
  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      fn entry, todo_list_acc ->
        add_entry(todo_list_acc, entry)
      end
    )
  end

  # The two arguments are:
  # a to-do list instance, generated by the previous new()
  # a Map describing the entry
  #
  # Example:
  # simple_map = %{date: ~D[2023-12-19], title: "Play"}
  # SimpleTodo.add_entry(%{}, simple_map)

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)

    new_entries =
      Map.put(
        todo_list.entries,
        todo_list.next_id,
        entry
      )

    %TodoList{todo_list | entries: new_entries, next_id: todo_list.next_id + 1}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(fn entry -> entry.date == date end)
  end

  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    %TodoList{todo_list | entries: Map.delete(todo_list.entries, entry_id)}
  end
end

defmodule TodoList.CsvImporter do
  def import(file_name) do
    file_name
    |> read_lines()
    |> create_entries()
    |> TodoList.new()
  end

  def read_lines(file_name) do
    file_name
    |> File.stream!()
    |> Stream.map(&String.trim_trailing(&1, "\n"))
  end

  defp create_entries(lines) do
    Stream.map(
      lines,
      fn line ->
        [date_string, title] = String.split(line, ",")
        date = Date.from_iso8601!(date_string)
        %{date: date, title: title}
      end
    )
  end
end
