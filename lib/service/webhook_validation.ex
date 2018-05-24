defmodule HomeAutomation.WebhookValidation do
  defmodule InvalidApiKeyError do
    @moduledoc """
    Error raised when no or a wrong api key is provided
    """

    defexception message: "Invalid api-key", plug_status: 400
  end

  def init(options), do: options

  def call(%Plug.Conn{request_path: path} = conn, opts) do
    if path in opts[:paths], do: verify_request!(conn.body_params)
    conn
  end

  defp verify_request!(body_params) do
    api_key = body_params["api_key"]
    webhook_api_key = Application.get_env(:home_automation, :webhook_api_key, nil)

    unless api_key == webhook_api_key, do: raise(InvalidApiKeyError)
  end
end
