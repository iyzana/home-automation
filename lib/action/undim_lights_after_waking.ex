defmodule HomeAutomation.UndimLightsAfterWaking do
  alias HomeAutomation.EventQueue
  use Timex
  require Logger

  @name "undim-lights-after-waking"

  # todo: create a protocol/behaviour for actions to implement a name, match and run method
  def register do
    # wake the pc when the phone comes online
    EventQueue.register(@name, [:webhook, :alarm_alert_dismiss], fn _ ->
      color_values = Application.get_env(:home_automation, :after_sleep_undim_color)
      dim_duration = Application.get_env(:home_automation, :after_sleep_undim_duration, 10 * 1000)

      {level, message} =
        cond do
          color_values == nil ->
            {:warn, "no after_sleep_color specified"}

          true ->
            color = %Lifx.Protocol.HSBK{
              hue: color_values.hue,
              saturation: color_values.saturation,
              brightness: color_values.brightness,
              kelvin: color_values.kelvin
            }

            Lifx.Client.devices()
            |> Enum.filter(fn light -> light.label == "light" end)
            |> Enum.map(& &1.id)
            |> Enum.each(&Lifx.Device.set_color(&1, color, dim_duration))

            {:info, "undimming lights"}
        end

      symbol = if level == :info, do: "✓", else: "✗"
      Logger.log(level, "#{@name} #{symbol} #{message}")
    end)
  end
end
