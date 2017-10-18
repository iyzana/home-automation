defmodule HomeAutomation.EventQueue do
  alias HomeAutomation.Actions
  alias __MODULE__
  require Logger
  use GenServer

  @type event :: [term, ...]

  @spec start_link(GenServer.options) :: Agent.on_start
  def start_link(opts) do
    result = GenServer.start_link(__MODULE__, :ok, opts)

    Actions.register_all()

    result
  end

  @spec register(String.t, [...], (event -> any)) :: :ok
  def register(name, matcher, callback) do
    # tuple = {name, callback}
    # append to callbacks if someone already registered, create a new entry otherwise
    # Agent.update(EventQueue, &Map.update(&1, matcher, [tuple], fn callbacks -> [tuple | callbacks] end))
    GenServer.call(EventQueue, {:register, name, matcher, callback})
  end

  @spec call(event) :: :ok
  def call(event) do
    GenServer.cast(EventQueue, {:call, event})
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:register, name, matcher, callback}, _from, listeners) do
    tuple = {name, callback}
    
    {:reply, :ok, Map.update(listeners, matcher, [tuple], fn callbacks -> [tuple | callbacks] end)}
  end

  def handle_cast({:call, event}, listeners) do
    Logger.debug("event-queue :: ← " <> inspect(event))

    listeners
    |> Enum.filter(fn {matcher, _} -> Enum.take(event, length(matcher)) == matcher end)
    |> Enum.flat_map(fn {_, callbacks} -> callbacks end)
    |> Enum.each(fn {_, callback} -> callback.(event) end)

    {:noreply, listeners}
  end
end
