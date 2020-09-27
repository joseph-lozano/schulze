defmodule Schulze.MixProject do
  use Mix.Project

  def project do
    [
      app: :schulze,
      version: "0.1.0",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: elixirc_options(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      consolidate_protocols: Mix.env() == :prod
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Schulze.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_options(:dev), do: [all_warnings: true]
  defp elixirc_options(:all), do: [warnings_as_errors: true]
  defp elixirc_options(_), do: [all_warnings: true] ++ elixirc_options(:all)

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Phoenix Deps
      {:phoenix, "~> 1.5.5"},
      {:phoenix_live_view, "~> 0.14.7"},
      {:phoenix_ecto, "~> 4.2"},
      {:floki, ">= 0.27.0", only: :test},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.2"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, "~> 0.15.6"},
      {:ecto_sql, "~> 3.4"},
      {:scrivener_ecto, "~> 2.0"},
      {:credo, "~> 1.1", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:libgraph, "~> 0.13.3"},
      {:phx_gen_auth, "~> 0.5", only: [:dev], runtime: false},
      {:bcrypt_elixir, "~> 2.0"},
      {:bamboo, "~> 1.5"},
      {:typed_ecto_schema, "~> 0.1.1"},
      {:accessible, "~> 0.2.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "cmd npm install --prefix assets", "ecto.setup"],
      "ecto.setup": ["ecto.create --quiet", "ecto.migrate --quiet"],
      "ecto.reset": ["ecto.drop --quiet", "ecto.setup"],
      test: ["ecto.setup", "test"],
      lint: [
        # --warnings as errors will not work if the code is already compiles
        "clean",
        "compile --warnings-as-errors",
        "format --check-formatted",
        "credo",
        "dialyzer"
      ]
    ]
  end
end
