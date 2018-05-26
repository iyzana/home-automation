defmodule HomeAutomation.NotifyOnUnknownDevice do
  alias HomeAutomation.EventQueue
  alias HomeAutomation.Device
  alias HomeAutomation.IFTTT
  use Timex
  require Logger

  @name "notify-on-unknown-device"

  # todo: create a protocol/behaviour for actions to implement a name, match and run method
  def register do
    # wake the pc when the phone comes online
    EventQueue.register(@name, [:device, :new], fn [_, _, dev] ->
      {level, message} =
        if dev.name != nil do
          {:debug, "device known"}
        else
          info = deviceinfo(dev)
          time = Timex.local()

          {status, result} =
            IFTTT.call_webhook("unknown_device", info, "#{time.hour}:#{time.minute}")

          case status do
            :ok ->
              {:info, "sending notification"}

            :error ->
              {:error, result}

            :failed ->
              {:warn,
               "ifttt returned #{result.status_code} #{inspect(Poison.decode!(result.body))}"}
          end
        end

      symbol = if level == :info, do: "✓", else: "✗"
      Logger.log(level, "#{@name} #{symbol} #{message}")
    end)
  end

  defp deviceinfo(%Device{mac: mac, vendor: vendor, ip: ip}) do
    cond do
      vendor != "" and mac != "" -> vendor <> " device " <> mac
      vendor != "" -> vendor <> " device"
      mac != "" -> "device " <> mac
      ip != "" -> "device " <> ip
      true -> "device"
    end
  end
end
