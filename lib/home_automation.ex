defmodule HomeAutomation do
  alias HomeAutomation.{EventQueue, Device}
  use Application
  require Logger

  def start(_type, _args) do
    port = Application.get_env(:home_automation, :cowboy_port, 8080)

    children = [
      Plug.Adapters.Cowboy2.child_spec(
        scheme: :http,
        plug: HomeAutomation.Router,
        options: [port: port]
      ),
      {EventQueue, name: EventQueue},
      {Device, name: Device}
    ]

    opts = [strategy: :one_for_one, name: HomeAutomation.Supervisor]

    Logger.info("application started")
    Supervisor.start_link(children, opts)
  end
end
