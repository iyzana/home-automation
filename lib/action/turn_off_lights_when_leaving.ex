defmodule HomeAutomation.TurnOffLightsWhenLeaving do
  alias HomeAutomation.{EventQueue, Person}
  require Logger

  @name "turn-off-lights-when-leaving"

  # todo: create a protocol/behaviour for actions to implement a name, match and run method
  def register do
    EventQueue.register(@name, [:person, :left], fn [:person, :left, %Person{name: name}] ->
      if name == "jannis" do
        Lifx.Client.devices()
        |> Enum.map(& &1.id)
        |> Enum.each(&Lifx.Device.off/1)

        Logger.info("turning of lights")
      end
    end)
  end
end
