defmodule HomeAutomation.Actions do
  def register_all do
    ["WakePcWhenArriving"]
    |> Enum.map(&"Elixir.HomeAutomation." <> &1)
    |> Enum.map(&String.to_atom/1)
    |> Enum.each(fn module -> module.register() end)
  end
end
