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
      {:ok, Ballot.add_vote(ballot, Map.merge(vote, missing_votes))}
    end
  end

  def get_winner(ballot) do
    candidates = ballot.candidates
    votes = ballot.votes

    pairs =
      for c1 <- candidates, c2 <- candidates do
        if c1 != c2, do: {c1, c2}
      end
      |> Enum.reject(&is_nil(&1))

    pairwise =
      pairs
      |> Enum.map(fn {c1, c2} ->
        c1_preferred =
          Enum.reduce(votes, 0, fn vote, acc ->
            c1_vote = Map.get(vote, c1, 0)
            c2_vote = Map.get(vote, c2, 0)
            if c1_vote > c2_vote, do: acc + 1, else: acc
          end)

        {{c1, c2}, c1_preferred}
      end)
      |> Enum.group_by(fn {{c1, c2}, _} -> Enum.sort([c1, c2]) end, fn {{c1, _}, preference} ->
        {c1, preference}
      end)
      |> Enum.map(fn {_pairing, [{c1, c1_votes}, {c2, c2_votes}]} ->
        cond do
          c1_votes > c2_votes -> {{c1, c2}, c1_votes}
          c2_votes > c1_votes -> {{c2, c1}, c2_votes}
          c1_votes == c2_votes -> nil
        end
      end)
      |> Enum.reject(&is_nil(&1))

    g =
      Graph.new()
      |> Graph.add_vertices([candidates])

    g =
      Enum.reduce(pairwise, g, fn {{c1, c2}, weight}, graph ->
        Graph.add_edge(graph, c2, c1, weight: weight)
      end)

    strongest_paths =
      pairs
      |> Enum.map(fn {c1, c2} = pair ->
        weight =
          Graph.get_paths(g, c1, c2)
          |> Enum.map(fn path ->
            path
            |> Enum.with_index()
            |> Enum.reduce([], fn {node, i}, acc ->
              next = Enum.at(path, i + 1)

              case next do
                nil -> acc
                _ -> acc ++ Graph.edges(g, node, next)
              end
            end)
            |> Enum.min_by(& &1.weight)
          end)
          |> Enum.max_by(& &1.weight)
          |> Map.get(:weight)

        {pair, weight}
      end)

    results =
      strongest_paths
      |> Enum.group_by(fn {{c1, c2}, _} -> Enum.sort([c1, c2]) end, fn {{c1, _}, strength} ->
        {c1, strength}
      end)
      |> Enum.map(fn {_pairing, [{c1, c1_votes}, {c2, c2_votes}]} ->
        cond do
          c1_votes > c2_votes -> c1
          c2_votes > c1_votes -> c2
          c1_votes == c2_votes -> nil
        end
      end)
      |> Enum.reject(&is_nil(&1))
      |> Enum.frequencies()

    results
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
