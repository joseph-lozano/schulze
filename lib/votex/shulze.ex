defmodule Votex.Shulze do
  def new_ballot(candidates) do
    if Enum.uniq(candidates) == candidates do
      {:ok, %__MODULE__.Ballot{candidates: candidates}}
    else
      {:error, "Candidates must be unique"}
    end
  end
end
