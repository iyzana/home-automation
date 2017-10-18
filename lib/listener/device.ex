defmodule HomeAutomation.Device do
  alias HomeAutomation.Network
  alias HomeAutomation.EventQueue
  alias __MODULE__
  require Logger
  use Agent

  defstruct [:name, :ip, :mac, :vendor, :last_online, online: false]

  def start_link(opts) do
    result = Agent.start_link(fn -> [] end, opts)

    spawn_link fn -> schedule_check_online() end

    result
  end

  defp schedule_check_online do
    check_online()
    Process.sleep(30000)
    schedule_check_online()
  end

  defp check_online do
    hosts = Network.list_hosts()

    Agent.update(Device, fn devices -> 
      new = create_new_devices(devices, hosts)

      update_devices(devices ++ new, hosts)
    end)
  end

  defp update_devices(devices, hosts) do
    Enum.map(devices, fn device -> # update device online status
      host = Enum.find(hosts, fn host -> host.mac == device.mac end)
      old_device = device

      online = host != nil
      was_online = device.online

      device = if online do
        %{device | 
          ip: host.ipv4,
          vendor: host.vendor,
          online: true,
          last_online: DateTime.utc_now}
      else
        %{device | online: false}
      end

      if online != was_online do
        new_state = if online, do: :online, else: :offline
        Logger.info("#{display_name(device)} went #{to_string(new_state)}")
        EventQueue.call([:device, new_state, device, old_device]) # todo: check if complete old device is require
      end

      device
    end)
  end

  defp create_new_devices(devices, hosts) do
    device_names = Application.get_env(:home_automation, :device_names, %{})
    device_macs = Enum.map(devices, fn device -> device.mac end)
    
    hosts
    |> Enum.filter(fn host -> host.mac not in device_macs end) # find out if device is already known by mac
    |> Enum.map(&%Device{ip: &1.ipv4, mac: &1.mac, vendor: &1.vendor, name: Map.get(device_names, &1.mac)})
    |> Stream.each(&EventQueue.call([:device, :new, &1]))
    |> Enum.to_list()
  end

  defp display_name(%Device{name: name, mac: mac, ip: ip}) do
    cond do
      name && name != "" -> name
      mac && mac != "" -> mac
      ip && ip != "" -> ip
    end
  end

  @doc"""
  return all known devices
  """
  @spec list_devices() :: [%Device{}]
  def list_devices do
    Agent.get(Device, fn devices -> devices end)
  end

  @spec find(String.t) :: %Device{}
  def find(name) do
    Agent.get(Device, &Enum.find(&1, fn device -> device.name == name end))
  end

  @spec offline_duration(%Device{online: boolean, last_online: DateTime}) :: non_neg_integer
  def offline_duration(%Device{online: online, last_online: last_online}) do
    cond do
      online -> 0
      last_online == nil -> 0
      true -> div(DateTime.diff(DateTime.utc_now(), last_online, :second), 60)
    end
  end

  @spec set_name(String.t, String.t) :: :ok
  def set_name(mac, name) do
    Agent.update Device, fn devices ->
      index = Enum.find_index(devices, fn device -> device.mac == mac end)
      List.update_at(devices, index, fn device -> %Device{device | name: name} end)
    end
  end
end
