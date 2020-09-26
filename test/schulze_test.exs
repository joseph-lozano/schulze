defmodule SchulzeTest do
  use Schulze.DataCase

  describe "get_winner/1" do
    test "1 vote, 1 winner" do
      votes = [
        %{"A" => 1, "B" => 2, "C" => 3, "D" => 4, "E" => 5}
      ]

      candidates = ~w(A B C D E)

      assert {:ok, won_election} =
               Schulze.create_election("TEST", candidates)
               |> elem(1)
               |> apply_votes(votes)
               |> Schulze.get_winner()

      assert won_election.winners == ~w(E D C B A) |> Enum.map(&[&1])
    end

    # https://electowiki.org/wiki/Schulze_method#Example_1
    test "Example 1" do
      candidates = ~w(A B C D E)

      compressed_votes = %{
        ~w(A C B E D) => 5,
        ~w(A D E C B) => 5,
        ~w(B E D A C) => 8,
        ~w(C A B E D) => 3,
        ~w(C A E B D) => 7,
        ~w(C B A D E) => 2,
        ~w(D C E B A) => 7,
        ~w(E B A D C) => 8
      }

      votes = get_votes(compressed_votes)

      assert {:ok, won_election} =
               Schulze.create_election("TEST 1", candidates)
               |> elem(1)
               |> apply_votes(votes)
               |> Schulze.get_winner()

      assert won_election.winners ==
               ~w(E A C B D)
               |> Enum.map(&[&1])
    end

    defp get_votes(votes) do
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

    defp apply_votes(election, votes) do
      Enum.reduce(votes, election, fn vote, acc ->
        with {:ok, b} <- Schulze.cast_vote(acc, vote) do
          b
        end
      end)
    end
  end

  describe "new_election/1" do
    test "starts a election with the candidates and no votes" do
      candidates = ["Alice", "Bob", "Charlie"]
      assert {:ok, %Schulze.Election{} = election} = Schulze.create_election("test", candidates)
      assert election.candidates == candidates
      assert election.votes == []
    end

    test "fails if 2 candidates share a name" do
      candidates = ["Alice", "Alice", "Bob", "Charlie"]
      assert {:error, "Candidates must be unique"} = Schulze.create_election("test", candidates)
    end
  end

  describe "cast_vote/2" do
    setup do
      {:ok, election} = Schulze.create_election("test", ["Alice", "Bob", "Charlie"])
      %{election: election}
    end

    test "takes votes correctly", %{election: election} do
      vote1 = %{"Alice" => 3, "Bob" => 2, "Charlie" => 1}
      {:ok, election1} = Schulze.cast_vote(election, vote1)
      assert election1.votes == [vote1]

      vote2 = %{"Alice" => 3, "Bob" => 1, "Charlie" => 1}
      {:ok, election2} = Schulze.cast_vote(election1, vote2)
      assert election2.votes == [vote2, vote1]
    end

    test "reject votes with a negative number", %{election: election} do
      vote = %{"Alice" => -1}
      assert {:error, "Preferences cannot be negative"} = Schulze.cast_vote(election, vote)
    end

    test "reject votes with a wrong candidate", %{election: election} do
      vote = %{"Doug" => 1}
      assert {:error, "Candidate not on election"} = Schulze.cast_vote(election, vote)
    end
  end
end
