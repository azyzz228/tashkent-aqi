defmodule TashkentAqNotifier.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TashkentAqNotifierWeb.Telemetry,
      # Start the Ecto repository
      TashkentAqNotifier.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: TashkentAqNotifier.PubSub},
      # Start Finch
      {Finch, name: TashkentAqNotifier.Finch},
      # Start the Endpoint (http/https)
      TashkentAqNotifierWeb.Endpoint,
      TashkentAqNotifier.Scheduler
      # Start a worker by calling: TashkentAqNotifier.Worker.start_link(arg)
      # {TashkentAqNotifier.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TashkentAqNotifier.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TashkentAqNotifierWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
