defmodule HomeAutomation.WakePcWhenArriving do
  alias HomeAutomation.EventQueue
  alias HomeAutomation.Device
  alias HomeAutomation.Network
  use Timex
  require Logger

  @name "wake-pc-when-arriving"

  # todo: create a protocol/behaviour for actions to implement a name, match and run method
  def register do
    # wake the pc when the phone comes online
    EventQueue.register @name, [:device, :online], fn [_, _, dev, old_dev] ->
      pc = Device.find("pc")

      {status, message} = cond do
        dev.name != "phone" ->
          {:debug, "not the phone"}
        Device.offline_duration(old_dev) < 30 ->
          {:debug, "phone recently online (" <> Integer.to_string(Device.offline_duration(old_dev)) <> " min ago)"}
        !pc ->
          {:warn, "pc does not exist"}
        pc.online ->
          {:debug, "pc already online"}
        Device.offline_duration(pc) < 60 ->
          {:debug, "pc recently online (" <> Integer.to_string(Device.offline_duration(pc)) <> " min ago)"}
        Timex.local().hour in 0..10 ->
          {:debug, "night hours"} 
        true ->
          Network.wake(pc.mac)
          {:info, "waking pc"}
      end

      symbol = if status == :info, do: "✓", else: "✗"
      Logger.log(status, "#{@name} #{symbol} #{message}")
    end
  end
end
