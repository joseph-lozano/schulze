defmodule Schulze.Election do
  @moduledoc """
  A struct and module for a Schulze Election
  Candidates are represented as strings.

  """
  use TypedEctoSchema
  import Ecto.Changeset
  alias Schulze.Accounts.User

  @type candidate :: String.t()
  @type candidate_list :: [candidate()]
  @type vote :: %{candidate() => pos_integer()}

  typed_schema "elections" do
    field(:name, :string, null: false)
    field(:candidates, {:array, :string}, default: [], null: false)
    field(:votes, {:array, :map}, default: [], null: false)
    field(:winners, {:array, {:array, :string}})
    field(:is_common, :boolean)
    field(:private, :boolean)
    field(:passwords, {:array, :string})
    field(:voters, :integer, virtual: true)
    belongs_to(:user, User)
  end

  def add_vote(election, vote) do
    update_in(election.votes, &[vote | &1])
  end

  @spec new(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          map
        ) :: Ecto.Changeset.t()
  def new(election, attrs) do
    is_common? = is_nil(attrs[:user_id])
    attrs = put_passwords(attrs)

    election
    |> cast(attrs, [:name, :candidates, :user_id, :passwords, :voters, :private])
    |> put_change(:is_common, is_common?)
    |> validate_required(:name)
    |> validate_number(:voters, greater_than_or_equal_to: 0, less_than_or_equal_to: 10_000)
    |> validate_length(:name, min: 3, max: 80)
    |> validate_length(:candidates, min: 2, max: 80)
    |> validate_change(:candidates, fn _, candidates ->
      if Enum.uniq(candidates) == candidates, do: [], else: [candidates: "must be unique"]
    end)
    |> Map.put(:action, :insert)
  end

  def winner(election, results) do
    change(election, winners: results)
  end

  def put_passwords(attrs) do
    case attrs[:voters] do
      nil -> Map.put(attrs, :passwords, []) |> Map.put(:private, false)
      "" -> Map.put(attrs, :passwords, []) |> Map.put(:private, false)
      0 -> Map.put(attrs, :passwords, []) |> Map.put(:private, false)
      x when x > 0 -> Map.put(attrs, :passwords, generate_passwords(x)) |> Map.put(:private, true)
    end
  end

  def generate_passwords(x) do
    generate_passwords(x, [])
  end

  def generate_passwords(x, list) when x > 0 do
    pw = :crypto.strong_rand_bytes(12) |> Base.encode64()
    generate_passwords(x - 1, [pw | list])
  end

  def generate_passwords(_, list) do
    list
  end
end
