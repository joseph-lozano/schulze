defmodule Votex.Schulze.Ballot do
  @moduledoc """
  A struct and module for a Schulze Ballot
  Candidates are represented as strings.

  Votes are taken as a map of candiate => strength of preference.
  These are converted into 2-dimensional lists to represent ties.
  For example, if A > B > C, then [[A], [B], [C]]
  If A is preferred, with no ranking given to B or C, then [[A], [B, C]] where the order of [B, C] does not matter

  The votes field on a struct shows the count of each vote
  """
  use TypedStruct

  @type candidate :: String.t()
  @type candidate_list :: [candidate()]
  @type vote :: %{candidate() => pos_integer()}

  typedstruct do
    field(:candidates, candidate_list(), default: [])
    field(:votes, %{[candidate_list()] => pos_integer()}, default: %{})
  end

  use Accessible

  @spec add_vote(t(), vote()) :: {:ok, t()}
  def add_vote(ballot, vote) do
    with {:ok, vote} <- validate(vote) do
      preference =
        Enum.group_by(vote, &elem(&1, 1), &elem(&1, 0))
        |> Enum.sort_by(&elem(&1, 0), &(&1 >= &2))
        |> Enum.map(&elem(&1, 1))

      {:ok, update_in(ballot, [:votes, preference], &increment(&1))}
    else
      e -> e
    end
  end

  defp increment(nil), do: 1
  defp increment(x), do: x + 1

  defp validate(vote) do
    try do
      for {candiate, preference} <- vote do
        if preference >= 0, do: {candiate, preference}, else: throw(:negative_preference)
      end
      |> ok()
    catch
      :negative_preference -> {:error, "Preferences cannot be negative"}
    end
  end

  defp ok(thing), do: {:ok, thing}
end
