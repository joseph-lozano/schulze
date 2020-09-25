defmodule Votex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Votex.Repo,
      # Start the Telemetry supervisor
      VotexWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Votex.PubSub},
      # Start the Endpoint (http/https)
      VotexWeb.Endpoint
      # Start a worker by calling: Votex.Worker.start_link(arg)
      # {Votex.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Votex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    VotexWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
