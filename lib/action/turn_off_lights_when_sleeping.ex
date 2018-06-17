defmodule HomeAutomation.TurnOffLightsWhenSleeping do
  alias HomeAutomation.EventQueue
  use Timex
  require Logger

  @name "turn-off-lights-when-sleeping"

  # todo: create a protocol/behaviour for actions to implement a name, match and run method
  def register do
    # wake the pc when the phone comes online
    EventQueue.register(@name, [:webhook, :sleep_tracking_started], fn _ ->
      get_data()
      |> run()
      |> log_result()
    end)
  end

  defp get_data do
    color =
      Application.get_env(:home_automation, :sleeping_color)
      |> map_to_color()

    dim_duration = Application.get_env(:home_automation, :sleeping_dim_duration, 10 * 1000)

    lights =
      Lifx.Client.devices()
      |> Enum.map(& &1.id)

    {color, dim_duration, lights}
  end

  defp run({nil, _, _}), do: {:warn, "no sleeping_color specified"}

  defp run({_, _, []}), do: {:warn, "no lights found"}

  defp run({color, dim_duration, lights}) do
    lights
    |> Enum.each(fn device ->
      spawn(fn ->
        Lifx.Device.set_color(device, color, dim_duration)
        Process.sleep(dim_duration)
        Lifx.Device.off(device)
      end)
    end)

    {:info, "dimming lights"}
  end

  defp map_to_color(nil), do: nil

  defp map_to_color(color_values) do
    %Lifx.Protocol.HSBK{
      hue: color_values.hue,
      saturation: color_values.saturation,
      brightness: color_values.brightness,
      kelvin: color_values.kelvin
    }
  end

  defp log_result({:info, message}), do: Logger.log(:info, "#{@name} ✓ #{message}")

  defp log_result({level, message}), do: Logger.log(level, "#{@name} ✗ #{message}")
end
