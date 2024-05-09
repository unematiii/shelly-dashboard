defmodule ShellyWeb.Router do
  use ShellyWeb, :router

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ShellyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ShellyWeb do
    pipe_through :browser

    live_session :default do
      live "/", DashboardLive.Dashboard

      live "/devices", DevicesLive.Index, :index
      live "/devices/new", DevicesLive.New, :new
      live "/devices/:id", DevicesLive.Edit, :edit

      live "/pricing", PricesLive.Index, :index
      live "/pricing/new", PricesLive.New, :new
      live "/pricing/:id", PricesLive.Edit, :edit
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", ShellyWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:shelly, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ShellyWeb.Telemetry
    end
  end
end
