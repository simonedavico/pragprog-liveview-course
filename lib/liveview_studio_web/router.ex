defmodule LiveviewStudioWeb.Router do
  use LiveviewStudioWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LiveviewStudioWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LiveviewStudioWeb do
    pipe_through :browser

    live "/", PageLive
    live "/light", LightLive
    live "/license", LicenseLive
    live "/sales-dashboard", SalesDashboardLive
    live "/search", SearchLive
    live "/flights", FlightsLive
    live "/autocomplete", AutocompleteLive
    live "/filter", FilterLive
    live "/repos", ReposLive
    live "/servers", ServersLive
    live "/servers/new", ServersLive, :new
    live "/paginate", PaginateLive
    live "/volunteers", VolunteersLive
    live "/infinite-scroll", InfiniteScrollLive
    live "/datepicker", DatePickerLive
    live "/sandbox", SandboxLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", LiveviewStudioWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: LiveviewStudioWeb.Telemetry
    end
  end
end
