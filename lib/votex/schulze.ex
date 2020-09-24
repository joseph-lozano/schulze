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

  @spec cast_vote(Ballot.t(), Ballot.vote()) :: {:ok, Ballot.t()} | {:error, reason :: term()}
  def cast_vote(ballot, vote) do
    missing_votes =
      (ballot.candidates -- Map.keys(vote))
      |> Enum.map(&{&1, 0})
      |> Enum.into(%{})

    with :ok <- validate(ballot, vote) do
      Ballot.add_vote(ballot, Map.merge(vote, missing_votes))
    end
  end

  defp validate(ballot, vote) do
    Enum.reduce_while(vote, :ok, fn {candidate, preference}, acc ->
      cond do
        preference < 0 -> {:halt, {:error, "Preferences cannot be negative"}}
        candidate not in ballot.candidates -> {:halt, {:error, "Candidate not on ballot"}}
        true -> {:cont, acc}
      end
    end)
  end
end
