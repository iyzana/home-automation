defmodule HomeAutomation.WakePcWhenArriving do
  alias HomeAutomation.EventQueue
  alias HomeAutomation.Device
  alias HomeAutomation.Network
  require Logger

  # todo: create a protocol/behaviour for actions to implement a name, match and run method
  def register do
    # wake the pc when the phone comes online
    EventQueue.register "wake-pc-when-arriving", [:device, :online], fn [_, _, dev, old_dev] ->
      {status, message} = cond do
        dev.name != "phone" -> {:error, "not the phone"}
        Device.offline_duration(old_dev) < 30 -> {:error, "phone recently online (" <> Integer.to_string(Device.offline_duration(old_dev)) <> " min ago)"}
        true -> 
          pc = Device.find("pc")

          cond do
            !pc -> {:error, "pc does not exist"}
            pc.online -> {:error, "pc already online"}
            Device.offline_duration(pc) < 60 -> {:error, "pc recently online (" <> Integer.to_string(Device.offline_duration(pc)) <> " min ago)"}
            true ->
              Network.wake(pc.mac)
              {:ok, "waking pc"}
          end
      end

      case status do
        :ok -> Logger.info("wake-pc-when-arriving :: ✓ " <> message)
        :error -> Logger.debug("wake-pc-when-arriving :: ✗ " <> message)
      end
    end
  end
end
