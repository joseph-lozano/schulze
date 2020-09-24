defmodule Votex.Schulze do
  alias __MODULE__.Ballot
  @spec new_ballot(Ballot.candidate_list()) :: {:ok, Ballot.t()} | {:error, reason :: term()}
  def new_ballot(candidates) do
    if Enum.uniq(candidates) == candidates do
      {:ok, %Ballot{candidates: candidates}}
    else
      {:error, "Candidates must be unique"}
    end
  end

  @spec cast_vote(Ballot.t(), Ballot.vote()) :: {:ok, Ballot.t()}
  def cast_vote(ballot, vote) do
    missing_votes =
      (ballot.candidates -- Map.keys(vote))
      |> Enum.map(&{&1, 0})
      |> Enum.into(%{})

    Ballot.add_vote(ballot, Map.merge(vote, missing_votes))
  end
end
