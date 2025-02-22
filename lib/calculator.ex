defmodule Calculator do
  # How to use this Calculator module
  #
  # iex(0)> calculator_pid = Calculator.start()
  # #PID<0.658.0>
  # iex(1)> Calculator.add(calculator_pid, 10)
  # {:add, 10}
  # iex(2)> Calculator.value(calculator_pid)
  # 10
  # iex(3)> Calculator.sub(calculator_pid, 5)
  # {:sub, 5}
  # iex(4)> Calculator.value(calculator_pid)
  # 5
  # iex(5)> Calculator.mul(calculator_pid, 3)
  # {:mul, 3}
  # iex(6)> Calculator.value(calculator_pid)
  # 15
  # iex(7)> Calculator.div(calculator_pid, 5)
  # {:div, 5}
  # iex(8)> Calculator.value(calculator_pid)
  # 3.0

  def start do
    # ↓ Start the Process and define 0 as the initial state
    spawn(fn ->
      loop(0)
    end)
  end

  def value(server_pid) do
    send(server_pid, {:value, self()})

    receive do
      {:response, value} ->
        value
    end
  end

  def add(server_pid, value), do: send(server_pid, {:add, value})
  def sub(server_pid, value), do: send(server_pid, {:sub, value})
  def mul(server_pid, value), do: send(server_pid, {:mul, value})
  def div(server_pid, value), do: send(server_pid, {:div, value})

  defp loop(current_value) do
    new_value =
      receive do
        message ->
          process_message(current_value, message)
      end

    # ↓ Recursivelly calls itself with the new state
    loop(new_value)
  end

  defp process_message(current_value, {:value, caller}) do
    send(caller, {:response, current_value})
    current_value
  end

  defp process_message(current_value, {:add, value}) do
    current_value + value
  end

  defp process_message(current_value, {:sub, value}) do
    current_value - value
  end

  defp process_message(current_value, {:mul, value}) do
    current_value * value
  end

  defp process_message(current_value, {:div, value}) do
    current_value / value
  end
end
