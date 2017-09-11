defmodule HomeAutomation.WakePcWhenArriving do
  alias HomeAutomation.EventQueue
  alias HomeAutomation.Device
  alias HomeAutomation.WakeOnLan

  def register do
    # wake the pc when the phone comes online
    EventQueue.register [:device, :online], fn [_, _, dev] ->
      if dev.name == "phone" do
        pc = Device.find("pc")

        if not pc.online and Device.offline_duration(pc) > 3600 do
          IO.puts ":: wake pc when arriving"
          WakeOnLan.send(pc.mac)
        end
      end
    end
  end
end
