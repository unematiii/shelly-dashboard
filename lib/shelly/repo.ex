defmodule Shelly.Repo do
  use Ecto.Repo,
    otp_app: :shelly,
    adapter: Ecto.Adapters.Postgres
end
