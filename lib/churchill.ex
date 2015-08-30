defmodule Churchill do
  def pmap(collection, fun, link \\ true, timeout \\ 5000) when is_function(fun) do
    master = self()
    worker = task(link)
    process = &send(master, {self(), fun.(&1)})

    processor = fn item ->
      worker.(fn -> process.(item) end)
    end
    receiver = fn {:ok, pid} ->
      receive do: ({^pid, result} -> result), after: (timeout -> nil)
    end

    collection |> Enum.map(processor) |> Enum.map(receiver)
  end

  defp task(true),  do: &Task.start_link(&1)
  defp task(false), do: &Task.start(&1)
end
