defmodule Votex.Storage do
  def all() do
    File.ls!("storage")
    |> Enum.reject(&(&1 == ".gitkeep"))
  end

  def save(identifier, term) do
    contents = :erlang.term_to_binary(term)
    File.write("storage/#{identifier}", contents, [:write])
  end

  def create(identifier, term) do
    contents = :erlang.term_to_binary(term)

    File.write("storage/#{identifier}", contents, [:exclusive])
    |> case do
      {:error, :eexist} -> {:error, :exists}
      :ok -> :ok
    end
  end

  def load(identifier) do
    case File.read("storage/#{identifier}") do
      {:ok, contents} -> {:ok, :erlang.binary_to_term(contents, [:safe])}
      _e -> {:error, :no_file}
    end
  end
end
