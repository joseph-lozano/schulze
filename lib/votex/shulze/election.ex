defmodule Votex.Schulze.Election do
  @moduledoc """
  A struct and module for a Schulze Election
  Candidates are represented as strings.

  """
  use TypedStruct

  @type candidate :: String.t()
  @type candidate_list :: [candidate()]
  @type vote :: %{candidate() => pos_integer()}

  typedstruct do
    field(:name, String.t(), enforce: true)
    field(:candidates, candidate_list(), default: [])
    field(:votes, [vote()], default: [])
  end

  def add_vote(election, vote) do
    update_in(election.votes, &[vote | &1])
  end
end
