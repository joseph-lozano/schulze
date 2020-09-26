use Mix.Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :votex, VotexWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :votex, Votex.Repo,
  database: "votex_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"

config :votex, Votex.Mailer, adapter: Bamboo.TestAdapter
