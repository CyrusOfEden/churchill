defmodule Benchmark.Sort do
  use Benchfella

  @a Enum.shuffle(1..250_000)

  bench "sequential sort" do
    Enum.sort(@a)
  end

  bench "parallel sort" do
    Churchill.sort(@a)
  end
end