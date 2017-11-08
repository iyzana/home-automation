defmodule HomeAutomation.IFTTT do
    def call_webhook(event, value1 \\ "", value2 \\ "", value3 \\ "") do
        api_key = Application.get_env(:home_automation, :ifttt_api_key)

        if api_key == nil or api_key == "" do
            {:error, "no ifttt_api_key specified"}
        else
            json = Poison.encode!(%{"value1" => value1, "value2" => value2, "value3" => value3})
            response = HTTPotion.post "https://maker.ifttt.com/trigger/#{event}/with/key/#{api_key}", body: json, headers: ["Content-Type": "application/json"]

            case response.status_code do
                200 -> {:ok, response}
                _ -> {:failed, response}
            end
        end
    end
end