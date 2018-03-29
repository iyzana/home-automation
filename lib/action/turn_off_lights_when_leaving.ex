defmodule HomeAutomation.TurnOffLightsWhenLeaving do
  alias HomeAutomation.EventQueue
  require Logger

  @name "turn-off-lights-when-leaving"

  # todo: create a protocol/behaviour for actions to implement a name, match and run method
  def register do
    # wake the pc when the phone comes online
    EventQueue.register(@name, [:device, :offline], fn [_, _, dev, old_dev] ->
      {status, message} =
        cond do
          dev.name != "phone" ->
            {:debug, "not the phone"}

          true ->
            Lifx.Client.devices()
            |> Enum.map(& &1.id)
            |> Enum.each(&Lifx.Device.off/1)

            {:info, "turning off lights"}
        end

      symbol = if status == :info, do: "✓", else: "✗"
      Logger.log(status, "#{@name} #{symbol} #{message}")
    end)
  end
end
