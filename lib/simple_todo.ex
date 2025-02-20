defmodule TodoList do
  # Struct that describes the To-do list
  defstruct next_id: 1, entries: %{}

  # Creates a new instance of the struct
  def new(), do: %TodoList{}

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
end
