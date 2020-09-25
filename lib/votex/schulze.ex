defmodule Votex.Schulze do
  alias __MODULE__.Election
  alias Votex.Storage

  def create_election(name, candidates) do
    with {:ok, election} <- new_election(name, candidates),
         :ok <- Storage.create(name, election) do
      VotexWeb.Endpoint.broadcast!(name, "new_election", %{election: election})
      {:ok, election}
    end
  end

  def save_election(name, election) do
    VotexWeb.Endpoint.broadcast!(name, "election_updated", %{})
    Storage.save(name, election)
  end

  def all_elections() do
    Storage.all()
  end

  def get_election(name) do
    Storage.load(name)
  end

  @spec new_election(String.t(), Election.candidate_list()) ::
          {:ok, Election.t()} | {:error, reason :: term()}
  def new_election(name, candidates) do
    cond do
      Enum.uniq(candidates) != candidates -> {:error, "Candidates must be unique"}
      length(candidates) < 2 -> {:error, "Need at least 2 candidates"}
      String.contains?(name, ":") -> {:error, "Invalid Character in Election name."}
      true -> {:ok, %Election{name: name, candidates: candidates}}
    end
  end

  @spec cast_vote(Election.t(), Election.vote()) ::
          {:ok, Election.t()} | {:error, reason :: term()}
  def cast_vote(election, vote) do
    missing_votes =
      (election.candidates -- Map.keys(vote))
      |> Enum.map(&{&1, 0})
      |> Enum.into(%{})

    with :ok <- validate(election, vote) do
      {:ok, Election.add_vote(election, Map.merge(vote, missing_votes))}
    end
  end

  def get_results(election) do
    candidates = election.candidates
    votes = election.votes

    pairs =
      for c1 <- candidates, c2 <- candidates do
        if c1 != c2, do: {c1, c2}
      end
      |> Enum.reject(&is_nil(&1))

    pairwise_winners = get_pairwise_winners(votes, pairs)
    g = build_graph(candidates, pairwise_winners)

    strongest_paths =
      pairs
      |> Enum.map(fn {c1, c2} = pair ->
        weight = get_strongest_path_weight(g, c1, c2)
        {pair, weight}
      end)

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
  end

  defp get_pairwise_winners(votes, pairs) do
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
  end

  defp build_graph(candidates, pairwise_winners) do
    g =
      Graph.new()
      |> Graph.add_vertices([candidates])

    Enum.reduce(pairwise_winners, g, fn {{c1, c2}, weight}, graph ->
      Graph.add_edge(graph, c2, c1, weight: weight)
    end)
  end

  defp get_strongest_path_weight(graph, node1, node2) do
    case Graph.get_paths(graph, node1, node2) do
      [] ->
        0

      paths ->
        paths
        |> Enum.map(fn path ->
          path
          |> Enum.with_index()
          |> Enum.reduce([], fn {node, i}, acc ->
            next = Enum.at(path, i + 1)

            case next do
              nil -> acc
              _ -> acc ++ Graph.edges(graph, node, next)
            end
          end)
          |> Enum.min_by(& &1.weight)
        end)
        |> Enum.max_by(& &1.weight)
        |> Map.get(:weight)
    end
  end

  def get_winner(%Election{} = election), do: get_results(election) |> get_winner(election)

  def get_winner(results, election) when is_map(results) do
    (election.candidates -- Map.keys(results))
    |> Enum.reduce(results, fn missing, acc -> Map.put(acc, missing, 0) end)
    |> Enum.group_by(fn {_candidate, strength} -> strength end, fn {candidate, _strength} ->
      candidate
    end)
    |> Enum.sort_by(fn {score, _} -> score end, &(&1 >= &2))
    |> Enum.map(&elem(&1, 1))
  end

  defp validate(election, vote) do
    Enum.reduce_while(vote, :ok, fn {candidate, preference}, acc ->
      cond do
        preference < 0 -> {:halt, {:error, "Preferences cannot be negative"}}
        candidate not in election.candidates -> {:halt, {:error, "Candidate not on election"}}
        true -> {:cont, acc}
      end
    end)
  end
end
