defmodule QuestionMachine.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      QuestionMachine.Server,
      {DynamicSupervisor, strategy: :one_for_one, name: QuestionMachine.ClientSupervisor}
    ]

    opts = [strategy: :one_for_one, name: QuestionMachine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
