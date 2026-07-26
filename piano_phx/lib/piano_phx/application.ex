defmodule PianoPhx.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PianoPhxWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:piano_phx, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PianoPhx.PubSub},
      # Start a worker by calling: PianoPhx.Worker.start_link(arg)
      # {PianoPhx.Worker, arg},
      # Start to serve requests, typically the last entry
      PianoPhxWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PianoPhx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PianoPhxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
