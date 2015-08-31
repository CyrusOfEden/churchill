defmodule ChurchillTest do
  use ExUnit.Case

  @a Enum.to_list(1..1000)
  @b Enum.shuffle(@a)

  test "parallel map" do
    assert Churchill.map(@a, &(&1 * &1)) == Enum.map(@a, &(&1 * &1))
  end
end
