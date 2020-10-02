alias Schulze

Logger.configure(level: :warn)

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
  Enum.map(votes, fn vote ->
    Task.async(fn ->
      {:ok, e} = Schulze.cast_vote(election, vote)
      length(e.votes)
    end)
  end)
  |> Enum.map(&Task.await(&1))
  |> Enum.each(&IO.puts(&1))
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
  apply_votes.(election, votes)
end

rand_vote = fn num_candidates -> :rand.uniform(num_candidates) end
candidates = ~w(Alice Bob Charlie Doug Ellie)

possible_votes =
  for a <- 1..5,
      b <- 1..5,
      c <- 1..5,
      d <- 1..5,
      e <- 1..5 do
    Enum.zip(candidates, [a, b, c, d, e])
    |> Enum.into(%{})
  end

rand_votes = fn times ->
  for _ <- 1..times do
    Enum.random(possible_votes)
  end
end
