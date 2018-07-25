defmodule HomeAutomation.WakePcWhenArriving do
  alias HomeAutomation.{EventQueue, Device, Network, Person}
  use Timex
  require Logger

  @name "wake-pc-when-arriving"

  # todo: create a protocol/behaviour for actions to implement a name, match and run method
  def register do
    # wake the pc when the phone comes online
    EventQueue.register(@name, [:person, :home], fn [_, _, %Person{name: name} = person] ->
      pc = Device.find("pc")

      {status, message} =
        cond do
          name != "jannis" ->
            {:debug, "not jannis"}

          Person.away_duration(person) < 30 ->
            {:debug,
             "jannis recently home (" <>
               Integer.to_string(Person.away_duration(person)) <> " min ago)"}

          !pc ->
            {:warn, "pc does not exist"}

          pc.online ->
            {:debug, "pc already online"}

          Device.offline_duration(pc) < 60 ->
            {:debug,
             "pc recently online (" <>
               Integer.to_string(Device.offline_duration(pc)) <> " min ago)"}

          Timex.local().hour in 0..10 ->
            {:debug, "night hours"}

          true ->
            Network.wake(pc.mac)
            {:info, "waking pc"}
        end

      symbol = if status == :info, do: "✓", else: "✗"
      Logger.log(status, "#{@name} #{symbol} #{message}")
    end)
  end
end
