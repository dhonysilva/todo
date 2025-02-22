defmodule DatabaseServer do
  # The interface Function
  # Stats the loop concurrently
  def start do
    spawn(&loop/0)
  end

  # Handles one message
  defp loop do
    # ↓ Awaits a message
    receive do
      {:run_query, caller, query_def} ->
        # ↓ Runs the query and sends the response to the caller
        query_result = run_query(query_def)
        send(caller, {:query_result, query_result})
    end

    # Recursively calls itself
    loop()
  end

  defp run_query(query_def) do
    # ↓ Simulates a long-running query
    Process.sleep(2000)
    "#{query_def} result"
  end
end
