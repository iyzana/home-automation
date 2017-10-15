defmodule HomeAutomation.WakePcWhenArriving do
  alias HomeAutomation.EventQueue
  alias HomeAutomation.Device
  alias HomeAutomation.Network

  # todo: create a protocol/behaviour for actions to implement a name, match and run method
  def register do
    # wake the pc when the phone comes online
    EventQueue.register "wake pc when arriving", [:device, :online], fn [_, _, dev] ->
      if dev.name == "phone" and Device.offline_duration(dev) > 30*60 do
        pc = Device.find("pc")

        if pc && not pc.online and Device.offline_duration(pc) > 60*60 do
          Network.wake(pc.mac)
        end
      end
    end
  end
end
