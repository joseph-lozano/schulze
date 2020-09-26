defmodule Schulze.Term do
  @moduledoc "Ecto Type for storing Elixir Terms"

  @behaviour Ecto.Type
  def type, do: :binary

  def cast(term), do: {:ok, term}

  def load(bin), do: {:ok, :erlang.binary_to_term(bin)}
  def dump(term), do: {:ok, term |> :erlang.term_to_binary()}
  def embed_as(_bin), do: :dump
  def equal?(a, b), do: a == b
end
