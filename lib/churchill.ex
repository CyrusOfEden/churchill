defmodule Churchill do
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
  def pmap(collection, fun, link \\ true, timeout \\ 5000) when is_function(fun) do
    master = self()

    process = &send(master, {self(), fun.(&1)})
    worker = case link do
      true ->
        &Task.start_link(fn -> process.(&1) end)
      false ->
        &Task.start(fn -> process.(&1) end)
    end
    receiver = fn {:ok, pid} ->
      receive do: ({^pid, result} -> result), after: (timeout -> nil)
    end

    collection |> Enum.map(worker) |> Enum.map(receiver)
  end
end
