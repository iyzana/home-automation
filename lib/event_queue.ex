defmodule HomeAutomation.EventQueue do
  use GenServer

  def start_link do
    Agent.start_link(fn -> %{} end, name: :event_listeners)
  end

  def register(matcher, callback) do
    # append to callbacks if someone already registered, create a new entry otherwise
    Agent.update(:event_listeners, &Map.update(&1, matcher, [callback], fn callbacks -> [callback | callbacks] end))
  end

  def call(event) do
    IO.puts "received event: " <> inspect(event)

    Agent.get(:event_listeners, fn map ->
      map
      |> Enum.filter(fn {matcher, _} -> Enum.zip(matcher, event) |> Enum.all?(fn {m, e} -> m == e end) end)
      |> Enum.flat_map(fn {_, callbacks} -> callbacks end)
    end)
    |> Enum.each(fn callback -> callback.(event) end)
  end
end
