alias Votex.Schulze
candidates = %{a: "Alice", b: "Bob", c: "Charlie", d: "Doug", e: "Ellie"}
candidate_names = Map.values(candidates)

# https://en.wikipedia.org/wiki/Schulze_method#Example
votes =
  %{
    ~w(a c b e d)a => 5,
    ~w(a d e c b)a => 5,
    ~w(b e d a c)a => 8,
    ~w(c a b e d)a => 3,
    ~w(c a e b d)a => 7,
    ~w(c b a d e)a => 2,
    ~w(d c e b a)a => 7,
    ~w(e b a d c)a => 8
  }
  |> Enum.flat_map(fn {ordering, times} ->
    Enum.map(1..times, fn _ ->
      ordering
      |> Enum.with_index(1)
      |> Enum.reduce(%{}, fn {candidate, i}, acc ->
        candidate = Map.get(candidates, candidate)
        Map.merge(%{candidate => i}, acc)
      end)
    end)
  end)

{:ok, fresh_ballot} = Schulze.new_ballot(candidate_names)

ballot =
  Enum.reduce(votes, fresh_ballot, fn vote, acc ->
    with {:ok, b} <- Schulze.cast_vote(acc, vote) do
      b
    end
  end)

pairs =
  for c1 <- candidate_names, c2 <- candidate_names do
    if c1 != c2, do: {c1, c2}
  end
  |> Enum.reject(&is_nil(&1))

pairwise =
  pairs
  |> Enum.map(fn {c1, c2} ->
    c1_preferred =
      Enum.reduce(votes, 0, fn vote, acc ->
        c1_vote = Map.get(vote, c1)
        c2_vote = Map.get(vote, c2)
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
  |> Graph.add_vertices([candidate_names])

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
|> Enum.sort_by(fn {_, count} -> count end, &(&1 >= &2))
|> hd()
|> elem(0)
|> IO.inspect()

System.halt(0)
