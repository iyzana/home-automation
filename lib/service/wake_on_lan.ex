defmodule HomeAutomation.WakeOnLan do
  import WOL

  def send(mac) do
    WOL.send(mac)
  end
end
