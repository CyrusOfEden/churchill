defmodule Benchmark.Map do
  use Benchfella

  @a Enum.shuffle(1..1000)

  def mapper(item) do
    trunc(:math.sqrt(item * 4 / 3) * 7)
  end

  def simulated_io(item) do
    :timer.sleep(:random.uniform(15))
    mapper(item)
  end

  bench "parallel map" do
    Churchill.map(@a, &mapper/1)
  end

  bench "sequential map" do
    Enum.map(@a, &mapper/1)
  end

  bench "parallel map with i/o" do
    Churchill.map(@a, &simulated_io/1)
  end

  bench "sequential map with i/o" do
    Enum.map(@a, &simulated_io/1)
  end
end