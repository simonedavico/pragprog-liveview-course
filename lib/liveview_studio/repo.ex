defmodule LiveviewStudio.Repo do
  use Ecto.Repo,
    otp_app: :liveview_studio,
    adapter: Ecto.Adapters.Postgres
end
