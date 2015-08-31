defmodule Churchill do
  @schedulers :erlang.system_info(:schedulers_online)

  @doc """
  Parallel map a collection.

  `collection`: Anything that implements the Enumerable protocol
  `fun`: The mapping function
  `link`: Whether to link the parallel worker to the current process. Defaults to `true`.
  `timeout`: The amount of time to wait for the worker to finish. Defaults to `5000`.

  ## Examples

      iex> Churchill.pmap(1..10, &(&1 + 5))
      [6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
  """
  def map(xs, fun, link \\ true, timeout \\ 5000, factor \\ @schedulers * 16)
  def map([], _, _, _, _), do: []
  def map(xs, fun, link, timeout, factor) do
    master = self()
    perform = case link do
      true  -> &Task.start_link(&1)
      false -> &Task.start(&1)
    end

    xs
    |> Enum.chunk(factor, factor, [])
    |> Enum.flat_map(fn chunk ->
      Enum.map(chunk, fn item ->
        perform.(fn ->
          send(master, {self(), fun.(item)})
        end)
      end)
    end)
    |> List.foldr([], fn {:ok, pid}, results ->
      receive do
        {^pid, result} -> [result|results]
      after
        timeout -> results
      end
    end)
  end
  defp process(false), do: &Task.start(&1)

  def sort(xs, factor \\ @schedulers)
  def sort(xs, 0), do: Enum.sort(xs)
  def sort(xs, _) when length(xs) <= 10_000, do: Enum.sort(xs)
  def sort(xs, factor) when factor > 0 do
    {ls, rs} = split(xs)
    next_factor = max(factor - 2, 0)

    lhs = Task.async(fn -> sort(ls, next_factor) end)
    rhs = Task.async(fn -> sort(rs, next_factor) end)

    merge(Task.await(lhs), Task.await(rhs))
  end

  # def sort_by(xs, mapper, sorter \\ &<=/2, factor \\ @schedulers) do
  #   collection
  #   |> Enum.map(&{&1, mapper.(&1)})
  #   |> sort(&sorter.(elem(&1, 1), elem(&2, 1)), factor)
  #   |> Enum.map(&elem(&1, 0))
  # end

  defp merge([], ys), do: ys
  defp merge(xs, []), do: xs
  defp merge([x|xt], [y|_] = ys) when x <= y, do: [x|merge(xt, ys)]
  defp merge([_|_] = xs, [y|yt]),             do: [y|merge(xs, yt)]

  defp split(xs), do: split([], xs, xs)
  defp split(l, [x|r], [_,_|xs]), do: split([x|l], r, xs)
  defp split(l, r, _), do: {l, r}
end
