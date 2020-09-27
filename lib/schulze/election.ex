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
    belongs_to(:user, User)
  end

  def add_vote(election, vote) do
    update_in(election.votes, &[vote | &1])
  end

  def new(election, attrs) do
    is_common? = is_nil(attrs[:user_id])

    election
    |> cast(attrs, [:name, :candidates])
    |> put_change(:is_common, is_common?)
    |> validate_required(:name)
    |> validate_length(:name, min: 3, max: 80)
    |> validate_length(:candidates, min: 2, max: 80)
    |> validate_change(:candidates, fn _, candidates ->
      if Enum.uniq(candidates) == candidates, do: [], else: [candidates: "must be unique"]
    end)
    |> validate_change(:candidates, fn _, candidates ->
      Enum.with_index(candidates, 1)
      |> Enum.reduce([], fn {candidate, i}, errors ->
        if candidate == "",
          do: [{:candidates, {"cannot be blank", [at_index: i]}} | errors],
          else: errors
      end)
    end)
    |> Map.put(:action, :insert)
  end

  def winner(election, results) do
    change(election, winners: results)
  end
end
