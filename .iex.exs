alias Votex.Schulze
candidates = %{A: "Alice", B: "Bob", C: "Charlie", D: "Doug", E: "Ellie"}
candidate_names = Map.values(candidates)

# https://electowiki.org/wiki/Schulze_method#Example_1
votes_1 = %{
  ~w(A C B E D)a => 5,
  ~w(A D E C B)a => 5,
  ~w(B E D A C)a => 8,
  ~w(C A B E D)a => 3,
  ~w(C A E B D)a => 7,
  ~w(C B A D E)a => 2,
  ~w(D C E B A)a => 7,
  ~w(E B A D C)a => 8
}

# https://electowiki.org/wiki/Schulze_method#Example_2
votes_2 = %{
  ~w(A C B D)a => 5,
  ~w(A C D B)a => 2,
  ~w(A D C B)a => 3,
  ~w(B A C D)a => 4,
  ~w(C B D A)a => 3,
  ~w(C D B A)a => 3,
  ~w(D A C B)a => 1,
  ~w(D B A C)a => 5,
  ~w(D C B A)a => 4
}

# https://electowiki.org/wiki/Schulze_method#Example_3
votes_3 = %{
  ~w(A B D E C)a => 3,
  ~w(A D E B C)a => 5,
  ~w(A D E C B)a => 1,
  ~w(B A D E C)a => 2,
  ~w(B D E C A)a => 2,
  ~w(C A B D E)a => 4,
  ~w(C B A D E)a => 6,
  ~w(D B E C A)a => 2,
  ~w(D E C A B)a => 5
}

# https://electowiki.org/wiki/Schulze_method#Example_4
votes_4 = %{
  ~w(A B C D)a => 3,
  ~w(D A B C)a => 2,
  ~w(D B C A)a => 2,
  ~w(C B D A)a => 2
}

get_votes = fn votes ->
  votes
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
end

get_ballot = fn votes ->
  candidate_names = votes |> Map.keys() |> hd |> Enum.map(&Map.get(candidates, &1))
  {:ok, ballot} = Schulze.new_ballot(candidate_names)

  Enum.reduce(get_votes.(votes), ballot, fn vote, acc ->
    with {:ok, b} <- Schulze.cast_vote(acc, vote) do
      b
    end
  end)
end

winner_1 =
  Schulze.get_winner(get_ballot.(votes_1))
  |> IO.inspect(label: 1)

winner_2 =
  Schulze.get_winner(get_ballot.(votes_2))
  |> IO.inspect(label: 2)

winner_3 =
  Schulze.get_winner(get_ballot.(votes_3))
  |> IO.inspect(label: 3)

winner_4 =
  Schulze.get_winner(get_ballot.(votes_4))
  |> IO.inspect(label: 4)