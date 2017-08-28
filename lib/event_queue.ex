defmodule HomeAutomation.EventQueue do
  use GenServer

  defmodule HomeAutomation.EventQueue.Event do
    defstruct [:type, :action, :data]
  end

  def start_link do
    Agent.start_link(fn -> {} end, name: :event_listeners)
  end

  def register(event, callback) do
    Agent.update(:event_listeners, &Map.update(&1, event, [], fn callbacks -> [callback | callbacks] end))
  end

  def call(event) do
    Agent.get(:event_listeners, &Map.get(&1, event, []))
    |> Enum.each(fn callback -> callback.(event) end)
  end
end
