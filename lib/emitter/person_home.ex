defmodule HomeAutomation.Person do
  alias HomeAutomation.EventQueue
  require Logger
  use Agent

  defstruct [:name, :location, :last_home, :asleep]

  def start_link(opts) do
    Agent.start_link(fn -> [] end, opts)
  end

  def find(name) do
    Agent.get(__MODULE__, fn persons -> persons.find(&(&1.name == name)) end)
  end

  def set_home(name) do
    person = find(name)
    EventQueue.call([:person, :home, person])

    Agent.update(__MODULE__, fn persons ->
      index = Enum.find_index(persons, fn p -> p.name == person.name end)

      List.update_at(
        persons,
        index,
        fn p -> %__MODULE__{p | location: "home", last_home: DateTime.utc_now()} end
      )
    end)
  end

  def set_left(name) do
    person = find(name)
    EventQueue.call([:person, :left, person])

    Agent.update(__MODULE__, fn persons ->
      index = Enum.find_index(persons, fn p -> p.name == person.name end)

      List.update_at(
        persons,
        index,
        fn p -> %__MODULE__{p | location: "gone"} end
      )
    end)
  end

  def set_asleep(name, asleep) do
    person = find(name)
    state = if asleep, do: :asleep, else: :awake
    EventQueue.call([:person, state, person])

    Agent.update(__MODULE__, fn persons ->
      index = Enum.find_index(persons, fn p -> p.name == person.name end)

      List.update_at(
        persons,
        index,
        fn p -> %__MODULE__{p | asleep: asleep} end
      )
    end)
  end

  def away_duration(%__MODULE__{location: location, last_home: last_home}) do
    cond do
      location == "home" -> 0
      last_home == nil -> 0
      true -> div(DateTime.diff(DateTime.utc_now(), last_home, :second), 60)
    end
  end

  def register do
    EventQueue.register(inspect(__MODULE__), [:device, :online], fn [:device, :online, dev, _] ->
      if dev.name == "phone" do
        set_home("jannis")
      end

      :ok
    end)

    EventQueue.register(
      inspect(__MODULE__),
      [:webhook, :person, :home],
      fn [:webhook, :person, :home, name] ->
        set_home(name)
      end
    )

    # EventQueue.register(inspect(Person), [:device, :offline], fn [_, _, dev, _] ->
    #   if dev.name == "phone" do
    #     EventQueue.call([:person, :left, "jannis"])
    #   end
    # end)

    EventQueue.register(
      inspect(__MODULE__),
      [:webhook, :person, :left],
      fn [:webhook, :person, :left, name] ->
        set_left(name)
      end
    )
  end
end
