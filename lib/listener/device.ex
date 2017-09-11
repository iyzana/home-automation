defmodule HomeAutomation.Device do
  alias HomeAutomation.Network, as: Network
  alias HomeAutomation.EventQueue, as: EventQueue
  alias __MODULE__, as: Device

  defstruct [:name, :ip, :mac, :vendor, :online, :last_online]

  def start_link do
    {:ok, _} = Agent.start_link(fn -> [] end, name: :device)

    spawn_link fn -> schedule_check_online() end
  end

  defp schedule_check_online do
    check_online()
    Process.sleep(60000)
    schedule_check_online()
  end

  defp check_online do
    hosts = Network.list_hosts()

    Agent.update(:device, fn devices -> 
      device_macs = Enum.map(devices, fn device -> device.mac end)

      # find out if device is already known by mac
      {existing, new} = Enum.split_with(hosts, fn host -> host.mac in device_macs end)

      update_devices(devices, existing) ++ create_devices(new)
    end)
  end

  defp update_devices(devices, hosts) do
    host_macs = Enum.map(hosts, fn host -> host.mac end)

    Enum.map(devices, fn device -> # update device online status
      online = device.mac in host_macs

      device = %{device |
        online: online,
        last_online: if(online, do: DateTime.utc_now, else: device.last_online)}

      if device.online and not online, do: EventQueue.call([:device, :offline, device])
      if not device.online and online, do: EventQueue.call([:device, :online, device])

      device
    end)
  end

  defp create_devices(hosts) do
    devices = Enum.map(hosts, &%Device{ip: &1.ipv4, mac: &1.mac, vendor: &1.vendor, online: true, last_online: DateTime.utc_now()})
    Enum.each(devices, fn device ->
      EventQueue.call([:device, :new, device])
      EventQueue.call([:device, :online, device])
    end)
    devices
  end

  @doc"""
  return all known devices
  """
  def list_devices do
    Agent.get(:device, fn devices -> devices end)
  end

  def find(name) do
    Agent.get(:device, &Enum.find(&1, fn device -> device.name == name end))
  end

  def offline_duration(%Device{online: online, last_online: last_online}) do
    if online, do: 0, else: DateTime.diff(DateTime.utc_now(), last_online, :second)
  end
end
