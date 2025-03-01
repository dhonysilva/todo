defmodule Todo.Server do
  use GenServer

  def start do
    GenServer.start(TodoServer, nil, name: :todo_server)
  end

  # Instruction on how to use this function to add an entry
  # TodoServer.add_entry(%{date: ~D[2023-12-19], title: "Dentist"})
  def add_entry(new_entry) do
    GenServer.cast(:todo_server, {:add_entry, new_entry})
  end

  def entries(date) do
    GenServer.call(:todo_server, {:entries, date})
  end

  @impl GenServer
  def init(_) do
    {:ok, Todo.List.new()}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, todo_list) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, todo_list) do
    {
      :reply,
      Todo.List.entries(todo_list, date),
      todo_list
    }
  end
end

defmodule Todo.List.CsvImporter do
  def import(file_name) do
    file_name
    |> read_lines()
    |> create_entries()
    |> Todo.List.new()
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
