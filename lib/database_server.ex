defmodule DatabaseServer do
  # The interface Function
  # Stats the loop concurrently
  def start do
    spawn(fn ->
      connection = :rand.uniform(1000)
      loop(connection)
    end)
  end

  # Handles one message
  defp loop(connection) do
    # ↓ Awaits a message
    receive do
      {:run_query, caller, query_def} ->
        # ↓ Runs the query and sends the response to the caller
        query_result = run_query(connection, query_def)
        send(caller, {:query_result, query_result})
    end

    # Recursively calls itself
    loop(connection)
  end

  defp run_query(connection, query_def) do
    # ↓ Simulates a long-running query
    Process.sleep(2000)
    "Connection #{connection}: #{query_def} result"
  end

  def run_async(server_pid, query_def) do
    send(server_pid, {:run_query, self(), query_def})
  end

  def get_result do
    receive do
      {:query_result, result} -> result
    after
      5000 -> {:error, :timeout}
    end
  end
end
