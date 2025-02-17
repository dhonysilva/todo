defmodule ListHelper do
  def sum([]), do: 0

  # The sum of the list's head plus the sum of list's tail applied recursively.
  # [1, 2, 3]
  # 1 + [2, 3]
  # 3 + [3]
  # 6
  def sum([head | tail]) do
    head + sum(tail)
  end
end
