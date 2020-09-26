alias Schulze.Impl
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

winners = fn num ->
  case num do
    1 -> [["Ellie"], ["Alice"], ["Charlie"], ["Bob"], ["Doug"]]
    _ -> []
  end
end

test = fn election, num ->
  if election.winners == winners.(num) do
    IO.puts("Election #{num} ok")
    Schulze.delete_election(election.id)
  else
    IO.warn("Election #{num} failed checks")
    Schulze.delete_election(election.id)
    System.halt()
  end
end

election_1 = get_election.(votes_1)
{:ok, winner_1} = Schulze.get_winner(election_1)
test.(winner_1, 1)

election_2 = get_election.(votes_2)
{:ok, winner_2} = Schulze.get_winner(election_2)
test.(winner_2, 2)

election_3 = get_election.(votes_3)
{:ok, winner_3} = Schulze.get_winner(election_3)
test.(winner_3, 3)

election_4 = get_election.(votes_4)
{:ok, winner_4} = Schulze.get_winner(election_4)
test.(winner_4, 4)

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
