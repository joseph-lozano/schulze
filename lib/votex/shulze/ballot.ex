defmodule Votex.Schulze.Ballot do
  @moduledoc """
  A struct and module for a Schulze Ballot
  Candidates are represented as strings.

  """
  use TypedStruct

  @type candidate :: String.t()
  @type candidate_list :: [candidate()]
  @type vote :: %{candidate() => pos_integer()}

  typedstruct do
    field(:candidates, candidate_list(), default: [])
    field(:votes, [vote()], default: [])
  end

  use Accessible

  def add_vote(ballot, vote) do
    update_in(ballot.votes, &[vote | &1])
  end
end
