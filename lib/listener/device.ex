defmodule HomeAutomation.Device do
  alias HomeAutomation.Network
  alias HomeAutomation.EventQueue
  alias __MODULE__

  defstruct [:name, :ip, :mac, :vendor, :last_online, online: false]

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
      new = create_new_devices(devices, hosts)

      update_devices(devices ++ new, hosts)
    end)
  end

  defp update_devices(devices, hosts) do
    host_macs = Enum.map(hosts, fn host -> host.mac end)

    Enum.map(devices, fn device -> # update device online status
      was_online = device.online
      online = device.mac in host_macs

      device = %{device |
        online: online,
        last_online: if(online, do: DateTime.utc_now, else: device.last_online)}

      if online != was_online do
        new_state = if online, do: :online, else: :offline
        EventQueue.call([:device, new_state, device])
      end

      device
    end)
  end

  defp create_new_devices(devices, hosts) do
    device_macs = Enum.map(devices, fn device -> device.mac end)
    
    hosts
    |> Enum.filter(fn host -> host.mac not in device_macs end) # find out if device is already known by mac
    |> Enum.map(&%Device{ip: &1.ipv4, mac: &1.mac, vendor: &1.vendor})
    |> Stream.each(&EventQueue.call([:device, :new, &1]))
    |> Enum.to_list()
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

  def set_name(mac, name) do
    # todo: Alternativly change the device list to a map based on the name
    Agent.update :device, fn devices ->
      index = Enum.find_idex(devices, fn device -> device.mac == mac)
      List.update_at(devices, index, fn device -> %Device{device | name: name})
    end
  end
end
