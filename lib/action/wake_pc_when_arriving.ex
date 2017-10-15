defmodule HomeAutomation.WakePcWhenArriving do
  alias HomeAutomation.EventQueue
  alias HomeAutomation.Device
  alias HomeAutomation.Network

  # todo: create a protocol/behaviour for actions to implement a name, match and run method
  def register do
    # wake the pc when the phone comes online
    EventQueue.register "wake-pc-when-arriving", [:device, :online], fn [_, _, dev, old_dev] ->
      cond do
        dev.name != "phone" ->
          "✗ not the phone"
          Device.offline_duration(old_dev) < 30 ->
          "✗ phone recently online (" <> Integer.to_string(Device.offline_duration(old_dev)) <> " min ago)"
        true -> 
          pc = Device.find("pc")

          cond do
            !pc ->
              "✗ pc does not exist"
            pc.online ->
              "✗ pc already online"
              Device.offline_duration(pc) < 60 ->
              "✗ pc recently online (" <> Integer.to_string(Device.offline_duration(pc)) <> " min ago)"
            true ->
              Network.wake(pc.mac)
              "✓ waking pc"
          end
      end
    end
  end
end
