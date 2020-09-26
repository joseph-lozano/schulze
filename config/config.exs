# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :schulze, ecto_repos: [Schulze.Repo]

# Configures the endpoint
config :schulze, SchulzeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "mPN0z9Zg1q/4Tve7uvzYUj9I/hU+3i8BNNoEVoKJDkYd/h+kjU3CAr8/Vr3Bx13N",
  render_errors: [view: SchulzeWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Schulze.PubSub,
  live_view: [signing_salt: "Ekqbfla8"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
