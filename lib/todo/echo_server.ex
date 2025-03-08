defmodule Todo.EchoServer do
  use GenServer

  def start_link(id) do
    GenServer.start_link(__MODULE__, nil, name: via_tuple(id))
  end

  def init(_) do
    {:ok, nil}
  end

  def call(id, some_request) do
    GenServer.call(via_tuple(id), some_request)
  end

  def via_tuple(id) do
    # {:via, some_mudule, some_arg}
    {:via, Registry, {:my_registry, {__MODULE__, id}}}
  end

  def handle_call(some_request, _from, state) do
    {:reply, some_request, state}
  end
end
