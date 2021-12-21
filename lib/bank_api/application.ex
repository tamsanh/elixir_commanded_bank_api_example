defmodule BankAPI.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      BankAPI.Repo,
      # Start the Telemetry supervisor
      BankAPIWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: BankAPI.PubSub},
      # Start the Endpoint (http/https)
      BankAPIWeb.Endpoint,
      BankAPI.CommandedApplication,
      BankAPI.Accounts.Supervisor
      # Start a worker by calling: BankAPI.Worker.start_link(arg)
      # {BankAPI.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BankAPI.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BankAPIWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
