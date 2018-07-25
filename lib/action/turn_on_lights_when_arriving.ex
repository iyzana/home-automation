defmodule HomeAutomation.TurnOnLightsWhenArriving do
  alias HomeAutomation.{EventQueue, Person}
  require Logger

  @name "turn-on-lights-when-arriving"

  # todo: create a protocol/behaviour for actions to implement a name, match and run method
  def register do
    EventQueue.register(@name, [:person, :home], fn [_, _, %Person{name: name, asleep: asleep}] ->
      cond do
        name != "jannis" ->
          Logger.info("not jannis")

        asleep ->
          Logger.info("jannis is asleep")

        true ->
          Lifx.Client.devices()
          |> Enum.filter(fn light -> light.label == "light" end)
          |> Enum.map(& &1.id)
          |> Enum.each(&Lifx.Device.on/1)

          Logger.info("turning on lights")
      end
    end)
  end
end
