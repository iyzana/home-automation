defmodule HomeAutomation.EventQueue do
  alias HomeAutomation.Actions
  alias __MODULE__
  use Agent

  @type event :: [term, ...]

  @spec start_link(GenServer.options) :: Agent.on_start
  def start_link(opts) do
    result = Agent.start_link(fn -> %{} end, opts)

    Actions.register_all()

    result
  end

  @spec register(String.t, [...], (event -> any)) :: :ok
  def register(name, matcher, callback) do
    tuple = {name, callback}
    # append to callbacks if someone already registered, create a new entry otherwise
    Agent.update(EventQueue, &Map.update(&1, matcher, [tuple], fn callbacks -> [tuple | callbacks] end))
  end

  @spec call(event) :: :ok
  def call(event) do
    IO.puts "event-queue :: ← " <> inspect(event)

    Agent.get(EventQueue, fn map ->
      map
      |> Enum.filter(fn {matcher, _} -> Enum.take(event, length(matcher)) == matcher end)
      |> Enum.flat_map(fn {_, callbacks} -> callbacks end)
    end)
    |> Enum.each(fn {name, callback} ->
      response = callback.(event)
      IO.puts "event-queue :: → " <> name <> " :: " <> response
    end)
  end
end
