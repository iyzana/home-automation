defmodule HomeAutomation.Network do
  import SweetXml

  def list_hosts do
    {stdout, 0} = System.cmd "nmap", ["-oX", "-", "-sn", "-n", "192.168.1.0/24"]
    xpath(stdout, ~x"/nmaprun/host/status[@state='up']/.."l,
                    ipv4: ~x"address[@addrtype='ipv4']/@addr",
                    mac: ~x"address[@addrtype='mac']/@addr",
                    vendor: ~x"address[@addrtype='mac']/@vendor")
  end
end
