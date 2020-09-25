defmodule Votex.Repo do
  use Ecto.Repo,
    otp_app: :votex,
    adapter: Ecto.Adapters.Postgres
end
