defmodule TodoServer do
  def start do
    ServerProcess.start(TodoServer)
  end

  # Instruction on how to use this function to add an entry
  # TodoServer.add_entry(%{date: ~D[2023-12-19], title: "Dentist"})
  def add_entry(new_entry) do
    send(:todo_server, {:add_entry, new_entry})
  end

  def entries(date) do
    ServerProcess.call(:todo_server, {:entries, date})
  end

  def init do
    TodoList.new()
  end

  def handle_cast({:add_entry, new_entry}, todo_list) do
    TodoList.add_entry(todo_list, new_entry)
  end

  def handle_call({:entries, date}, todo_list) do
    {TodoList.entries(todo_list, date), todo_list}
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
