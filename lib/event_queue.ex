defmodule HomeAutomation.EventQueue do
  use GenServer

  def start_link do
    Agent.start_link(fn -> %{} end, name: :event_listeners)
  end

  def register(name, matcher, callback) do
    tuple = {name, callback}
    # append to callbacks if someone already registered, create a new entry otherwise
    Agent.update(:event_listeners, &Map.update(&1, matcher, [tuple], fn callbacks -> [tuple | callbacks] end))
  end

  def call(event) do
    IO.puts "[<] " <> inspect(event)

    Agent.get(:event_listeners, fn map ->
      map
      |> Enum.filter(fn {matcher, _} -> Enum.zip(matcher, event) |> Enum.all?(fn {m, e} -> m == e end) end)
      |> Enum.flat_map(fn {_, callbacks} -> callbacks end)
    end)
    |> Enum.each(fn {name, callback} ->
      IO.puts "[>] " <> name
      callback.(event)
    end)
  end
end
