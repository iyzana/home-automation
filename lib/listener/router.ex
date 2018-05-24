defmodule HomeAutomation.Router do
  alias HomeAutomation.EventQueue
  use Plug.Router

  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:urlencoded])
  plug(:match)
  plug(:dispatch)

  post "/time_to_bed_alarm_alert" do
    api_key = conn.body_params["api_key"]
    webhook_api_key = Application.get_env(:home_automation, :webhook_api_key, nil)

    if api_key != webhook_api_key do
      send_resp(conn, 400, "Invalid api-key")
    else
      EventQueue.call([:webhook, :time_to_bed_alarm_alert])
      send_resp(conn, 200, "Success")
    end
  end

  match(_, do: send_resp(conn, 404, "Oops!"))
end
