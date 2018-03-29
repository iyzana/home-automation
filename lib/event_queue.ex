defmodule HomeAutomation.EventQueue do
  alias HomeAutomation.Actions
  alias __MODULE__
  require Logger
  use GenServer

  @type event :: [term, ...]

  @spec start_link(GenServer.options()) :: Agent.on_start()
  def start_link(opts) do
    result = GenServer.start_link(__MODULE__, :ok, opts)

    Lifx.Client.start_link()
    Lifx.Client.start()
    Actions.register_all()

    result
  end

  @spec register(String.t(), [...], (event -> any)) :: :ok
  def register(name, matcher, callback) do
    GenServer.cast(EventQueue, {:register, name, matcher, callback})
  end

  @spec call(event) :: :ok
  def call(event) do
    GenServer.cast(EventQueue, {:dispatch, event})
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({:register, name, matcher, callback}, state) do
    tuple = {name, callback}

    {:noreply, Map.update(state, matcher, [tuple], fn callbacks -> [tuple | callbacks] end)}
  end

  def handle_cast({:dispatch, event}, state) do
    Logger.debug("event-queue ← " <> inspect(event))

    state
    |> Enum.filter(fn {matcher, _} -> Enum.take(event, length(matcher)) == matcher end)
    |> Enum.flat_map(fn {_, callbacks} -> callbacks end)
    |> Enum.each(fn {_, callback} -> callback.(event) end)

    {:noreply, state}
  end
end
