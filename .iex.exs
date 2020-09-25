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

# Schulze.get_winner(ballot)
