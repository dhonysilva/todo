defmodule Todo.Cache do
  use GenServer

  def start_link(_) do
    # This is the basic structure of a GenServer.start_link:
    # GenServer.start_link(calback_module, some_arg, name: some_name)
    #
    # name option can also be a via tuple:
    # GenServer.start_link(calback_module, some_arg, name: {:via, some_name, some_arg})
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(todo_list_name) do
    GenServer.call(__MODULE__, {:server_process, todo_list_name})
  end

  @impl GenServer
  def init(_) do
    IO.puts("Starting To-do Cache.")
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}

      :error ->
        {:ok, new_server} = Todo.Server.start_link(todo_list_name)

        {
          :reply,
          new_server,
          Map.put(todo_servers, todo_list_name, new_server)
        }
    end
  end
end
