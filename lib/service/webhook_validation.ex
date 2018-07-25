defmodule HomeAutomation.WebhookValidation do
  defmodule InvalidApiKeyError do
    @moduledoc """
    Error raised when no or a wrong api key is provided
    """

    defexception message: "Invalid api-key", plug_status: 400
  end

  def init(options), do: options

  def call(%Plug.Conn{request_path: path, params: params} = conn, opts) do
    if path not in opts[:except] do
      verify_request!(params)
    end
    conn
  end

  defp verify_request!(params) do
    api_key = params["api_key"]
    webhook_api_key = Application.get_env(:home_automation, :webhook_api_key, nil)

    unless api_key == webhook_api_key, do: raise(InvalidApiKeyError)
  end
end
