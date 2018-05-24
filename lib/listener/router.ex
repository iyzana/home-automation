defmodule HomeAutomation.Router do
  alias HomeAutomation.EventQueue
  alias HomeAutomation.WebhookValidation
  use Plug.Router
  use Plug.ErrorHandler

  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:urlencoded])

  plug(
    WebhookValidation,
    paths: ["/time_to_bed_alarm_alert", "/alarm_alert_dismiss"]
  )

  plug(:match)
  plug(:dispatch)

  post "/time_to_bed_alarm_alert" do
    EventQueue.call([:webhook, :time_to_bed_alarm_alert])
    send_resp(conn, 200, "Success")
  end

  post "/alarm_alert_dismiss" do
    EventQueue.call([:webhook, :alarm_alert_dismiss])
    send_resp(conn, 200, "Success")
  end

  match(_, do: send_resp(conn, 404, "Oops!"))
end
