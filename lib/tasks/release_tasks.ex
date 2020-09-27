defmodule Schulze.ReleaseTasks do
  @moduledoc """
  Module responsible for kicking off tasks inside a release.

  Taken and modified from: https://hexdocs.pm/distillery/guides/running_migrations.html
  """

  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto,
    :ecto_sql
  ]

  def migrate do
    start_services()

    run_migrations()

    IO.puts("Success!")
  end

  defp start_services do
    IO.puts("Starting dependencies..")
    # Start apps necessary for executing migrations
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    # Load the app
    Application.load(:schulze)

    # Start the Repo(s) for app
    IO.puts("Starting repos..")

    # pool_size can be 1 for ecto < 3.0
    Enum.each(repos(), & &1.start_link(pool_size: 2))
  end

  defp run_migrations do
    Enum.each(repos(), &run_migrations_for/1)
  end

  defp run_migrations_for(repo) do
    app = Keyword.get(repo.config(), :otp_app)
    migrations_path = priv_path_for(repo, "migrations")
    IO.puts("Running migrations for #{app}, #{inspect(repo)}, path: #{inspect(migrations_path)}")
    Ecto.Migrator.run(repo, [migrations_path], :up, all: true)
  end

  defp priv_path_for(repo, filename) do
    app = Keyword.get(repo.config(), :otp_app)
    priv_dir = "#{:code.priv_dir(app)}"
    repo_path = repo_base_path(repo)
    Path.join([priv_dir, repo_path, filename])
  end

  defp repo_base_path(repo) do
    case Keyword.get(repo.config(), :priv) do
      nil ->
        repo
        |> Module.split()
        |> List.last()
        |> Macro.underscore()

      path ->
        String.replace(path, "priv/", "")
    end
  end

  defp repos do
    Application.get_env(:schulze, :ecto_repos)
  end
end
