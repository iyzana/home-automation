defmodule HomeAutomation.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get("/webhook", do: send_resp(conn, 200, "Welcome"))
  match(_, do: send_resp(conn, 404, "Oops!"))
end
