defmodule KeyValueStore do
  use GenServer

  def init(_) do
    :timer.send_interval(5000, :cleanup)
    {:ok, %{}}
  end

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def handle_info(:cleanup, state) do
    IO.puts("Performing cleanup.")
    {:noreply, state}
  end

  def put(key, value) do
    GenServer.cast(__MODULE__, {:put, key, value})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  # Handles the put request
  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  # Handles the get request
  def handle_call({:get, key}, _, state) do
    {:reply, Map.get(state, key), state}
  end
end
