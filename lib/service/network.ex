defmodule HomeAutomation.Network do
  import SweetXml

  @spec list_hosts() :: [%{ipv4: String.t, mac: String.t | nil, vendor: String.t | nil}]
  def list_hosts do
    network = Application.get_env(:home_automation, :network)
    {stdout, 0} = System.cmd "nmap", ["-oX", "-", "-sn", "-n", network]
    xpath(stdout, ~x"/nmaprun/host/status[@state='up']/.."l,
                    ipv4: ~x"address[@addrtype='ipv4']/@addr"s,
                    mac: ~x"address[@addrtype='mac']/@addr"s,
                    vendor: ~x"address[@addrtype='mac']/@vendor"s)
  end

  @spec wake(String.t) :: :ok
  def wake(mac) do
    WOL.send(mac)
  end
end
