defmodule HomeAutomation.WakePcWhenArriving do
  alias HomeAutomation.EventQueue
  alias HomeAutomation.Device
  alias HomeAutomation.Network

  # todo: create a protocol/behaviour for actions to implement a name, match and run method
  def register do
    # wake the pc when the phone comes online
    EventQueue.register "wake pc when arriving", [:device, :online], fn [_, _, dev] ->
      cond do
        dev.name != "phone" -> IO.puts "wake-pc-when-arriving :: ✗ not the phone"
        Device.offline_duration(dev) < 30 * 60 -> "wake-pc-when-arriving :: ✗ insignificant offline time (" <> Device.offline_duration(dev) / 60 <> "min)"
        true -> 
          pc = Device.find("pc")

          cond do
            !pc -> "wake-pc-when-arriving :: ✗ pc does not exist"
            pc.online -> "wake-pc-when-arriving :: ✗ pc already online"
            Device.offline_duration(pc) < 60 * 60 -> "wake-pc-when-arriving :: ✗ pc recently online (" <> Device.offline_duration(pc) <> " min ago)"
            true ->
              Network.wake(pc.mac)
              IO.puts "wake-pc-when-arriving :: ✓ waking pc"
          end
      end
  end
end
