defmodule LiveviewStudio.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LiveviewStudioWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: LiveviewStudio.PubSub},
      # Start the Endpoint (http/https)
      LiveviewStudioWeb.Endpoint,
      # Start a worker by calling: LiveviewStudio.Worker.start_link(arg)
      # {LiveviewStudio.Worker, arg}
      {LiveviewStudio.Repo, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveviewStudio.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveviewStudioWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
