defmodule HomeAutomation.Supervisor do
    alias HomeAutomation.EventQueue
    alias HomeAutomation.Device
    alias HomeAutomation.Actions
    use Supervisor

    def start_link(opts) do
       Supervisor.start_link(__MODULE__, :ok, opts) 
    end

    def init(:ok) do
        children = [
            EventQueue,
            Device
        ]

        Supervisor.init(children, strategy: :one_for_one)
    end
end