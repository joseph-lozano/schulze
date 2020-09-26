defmodule Schulze.Repo do
  use Ecto.Repo,
    otp_app: :schulze,
    adapter: Ecto.Adapters.Postgres
end
