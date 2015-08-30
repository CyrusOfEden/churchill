defmodule CurchillTest do
  use ExUnit.Case

  @a Enum.to_list(1..1000)
  @b Enum.shuffle(@a)

  test "mergesort" do
    assert Churchill.mergesort(@b) == @a
  end
end
