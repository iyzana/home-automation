defmodule HomeAutomation do
  use Application
  alias HomeAutomation.EventQueue
  alias HomeAutomation.Device
  alias HomeAutomation.Actions

  def start(_type, _args) do
    HomeAutomation.Supervisor.start_link(name: HomeAutomation.Supervisor)
  end
end
