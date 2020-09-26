alias Schulze.Impl

votes = %{
  # https://electowiki.org/wiki/Schulze_method#Example_1
  1 => %{
    ~w(A C B E D) => 5,
    ~w(A D E C B) => 5,
    ~w(B E D A C) => 8,
    ~w(C A B E D) => 3,
    ~w(C A E B D) => 7,
    ~w(C B A D E) => 2,
    ~w(D C E B A) => 7,
    ~w(E B A D C) => 8
  },

  # https://electowiki.org/wiki/Schulze_method#Example_2
  2 => %{
    ~w(A C B D) => 5,
    ~w(A C D B) => 2,
    ~w(A D C B) => 3,
    ~w(B A C D) => 4,
    ~w(C B D A) => 3,
    ~w(C D B A) => 3,
    ~w(D A C B) => 1,
    ~w(D B A C) => 5,
    ~w(D C B A) => 4
  },

  # https://electowiki.org/wiki/Schulze_method#Example_3
  3 => %{
    ~w(A B D E C) => 3,
    ~w(A D E B C) => 5,
    ~w(A D E C B) => 1,
    ~w(B A D E C) => 2,
    ~w(B D E C A) => 2,
    ~w(C A B D E) => 4,
    ~w(C B A D E) => 6,
    ~w(D B E C A) => 2,
    ~w(D E C A B) => 5
  },

  # https://electowiki.org/wiki/Schulze_method#Example_4
  4 => %{
    ~w(A B C D) => 3,
    ~w(D A B C) => 2,
    ~w(D B C A) => 2,
    ~w(C B D A) => 2
  }
}

winners = fn num ->
  case num do
    1 -> [["E"], ["A"], ["C"], ["B"], ["D"]]
    _ -> []
  end
end

test = fn election, num ->
  if election.winners == winners.(num) do
    IO.puts("Election #{num} ok")
  else
    IO.inspect(election)
    IO.warn("Got #{inspect(election.winners)}, expected: #{inspect(winners.(num))}")
    Schulze.delete_election(election.id)
    System.halt(1)
  end
end

decompress = fn votes ->
  votes
  |> Enum.flat_map(fn {ordering, times} ->
    Enum.map(1..times, fn _ ->
      ordering
      |> Enum.reverse()
      |> Enum.with_index(1)
      |> Enum.reduce(%{}, fn {candidate, i}, acc ->
        Map.merge(%{candidate => i}, acc)
      end)
    end)
  end)
end

apply_votes = fn election, votes ->
  Enum.reduce(votes, election, fn vote, acc ->
    with {:ok, e} <- Schulze.cast_vote(acc, vote) do
      e
    end
  end)
end

setup_election = fn num ->
  votes =
    votes
    |> Map.get(num)
    |> decompress.()

  candidates =
    hd(votes)
    |> Map.keys()

  {:ok, election} = Schulze.create_election("Sample Election ##{num}", candidates)
  election = apply_votes.(election, votes)
end

setup_election.(1)
setup_election.(2)
setup_election.(3)
setup_election.(4)

# {:ok, election_1} = Schulze.create_election("Example Election 1", ~w(A B C D E))

# {:ok, winner_1} =
#   election_1
#   |> apply_votes.(get_votes.(votes_1))
#   |> Schulze.get_winner()

# test.(winner_1, 1)

# IO.puts("Generating random votes")

# :random.seed(:os.timestamp())

# {rand_time, rand_votes} =
#   :timer.tc(fn ->
#     Enum.map(1..votes, fn _ ->
#       for candidate <- candidate_names, into: %{} do
#         rand = :random.uniform(5)
#         {candidate, rand}
#       end
#     end)
#   end)

# IO.puts("Took #{div(rand_time, 1000)} to generate all the votes")

# IO.puts("START CREATE ELECTION")

# {create_election_time, rand_election} =
#   :timer.tc(fn ->
#     rand_name =
#       :crypto.strong_rand_bytes(10)
#       |> Base.url_encode64()
#       |> binary_part(0, 10)

#     {:ok, new_election} = Schulze.create_election(rand_name, candidate_names)

#     election =
#       Enum.reduce(rand_votes, new_election, fn vote, acc ->
#         {:ok, election} = Schulze.cast_vote(acc, vote)
#         election
#       end)

#     Schulze.update_election(election.name, election)
#     election
#   end)

# IO.inspect(div(create_election_time, 1000), label: "CREATE ELECTION")

# {get_winner_time, winner} = :timer.tc(fn -> Schulze.get_winner(rand_election) end)
