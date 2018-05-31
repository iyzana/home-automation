defmodule HomeAutomation.ToggleLightOnRequest do
  alias HomeAutomation.EventQueue
  use Timex
  require Logger

  @name "toggle-light-on-request"

  def register do
    # wake the pc when the phone comes online
    EventQueue.register(@name, [:webhook, :toggle_light], fn _ ->
      get_data()
      |> run()
      |> log_result()
    end)
  end

  defp get_data do
    Lifx.Client.devices()
    |> Enum.filter(fn light -> light.label == "light" end)
  end

  defp run([]), do: {:warn, "no lights found"}

  defp run(lights) do
    lights
    |> Enum.each(&toggle/1)

    {:info, "toggling lights"}
  end

  defp toggle(%Lifx.Device.State{power: 0, id: id}), do: Lifx.Device.on(id)

  defp toggle(%Lifx.Device.State{power: 65535, id: id}), do: Lifx.Device.off(id)

  defp log_result({:info, message}), do: Logger.log(:info, "#{@name} ✓ #{message}")

  defp log_result({level, message}), do: Logger.log(level, "#{@name} ✗ #{message}")
end
