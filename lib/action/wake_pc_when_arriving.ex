defmodule HomeAutomation.WakePcWhenArriving do
  alias HomeAutomation.EventQueue
  alias HomeAutomation.Device
  alias HomeAutomation.Network

  # todo: create a protocol/behaviour for actions to implement a name, match and run method
  def register do
    # wake the pc when the phone comes online
    EventQueue.register "wake-pc-when-arriving", [:device, :online], fn [_, _, dev] ->
      cond do
        dev.name != "phone" ->
          "✗ not the phone"
        Device.offline_duration(dev) < 30 * 60 ->
          "✗ phone recently online (" <> to_minute_string(Device.offline_duration(dev)) <> " min ago)"
        true -> 
          pc = Device.find("pc")

          cond do
            !pc ->
              "✗ pc does not exist"
            pc.online ->
              "✗ pc already online"
            Device.offline_duration(pc) < 60 * 60 ->
              "✗ pc recently online (" <> to_minute_string(Device.offline_duration(pc)) <> " min ago)"
            true ->
              Network.wake(pc.mac)
              "✓ waking pc"
          end
      end
    end
  end

  defp to_minute_string(seconds) do
    Integer.to_string(trunc(seconds / 60) + 1)
  end
end
