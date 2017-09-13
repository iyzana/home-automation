defmodule HomeAutomation.WakePcWhenArriving do
  alias HomeAutomation.EventQueue
  alias HomeAutomation.Device
  alias HomeAutomation.WakeOnLan

  # todo: create a protocol/behaviour for actions to implement a name, match and run method
  def register do
    # wake the pc when the phone comes online
    EventQueue.register "wake pc when arriving", [:device, :online], fn [_, _, dev] ->
      if dev.name == "phone" do
        pc = Device.find("pc")

        if not pc.online and Device.offline_duration(pc) > 3600 do
          WakeOnLan.send(pc.mac)
        end
      end
    end
  end
end
