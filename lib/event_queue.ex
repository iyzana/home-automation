defmodule HomeAutomation.EventQueue do
  alias HomeAutomation.Actions
  use Agent

  @type event :: [term, ...]

  def start_link(_opts) do
    result = Agent.start_link(fn -> %{} end, name: :event_listeners)

    Actions.register_all()

    result
  end

  @spec register(String.t, [...], (event -> any)) :: :ok
  def register(name, matcher, callback) do
    tuple = {name, callback}
    # append to callbacks if someone already registered, create a new entry otherwise
    Agent.update(:event_listeners, &Map.update(&1, matcher, [tuple], fn callbacks -> [tuple | callbacks] end))
  end

  @spec call(event) :: :ok
  def call(event) do
    IO.puts "[<] " <> inspect(event)

    Agent.get(:event_listeners, fn map ->
      map
      |> Enum.filter(fn {matcher, _} -> Enum.take(event, length(matcher)) == matcher end)
      |> Enum.flat_map(fn {_, callbacks} -> callbacks end)
    end)
    |> Enum.each(fn {name, callback} ->
      IO.puts "[>] " <> name
      callback.(event)
    end)
  end
end
